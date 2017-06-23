//
//  NewsfeedTableViewController.swift
//
//
//  Created by Erica Y Stevens on 5/7/17.
//
//

import UIKit
import Firebase

class NewsfeedTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Stored Properties
    
    let dummyData = [UIImage(named: "Yoga Movement Beyonce Knowles"), UIImage(named: "beyYoga2"), UIImage(named: "beyYoga3") ]
    
    var namaskarOffered = false
    let timestampLabels = ["2w", "3w", "1m"]
    let userAsanaGoals: [[String:[UIImage]]] = [
        ["Dancer Pose" : [#imageLiteral(resourceName: "Dancer3"), #imageLiteral(resourceName: "Dancer2"), #imageLiteral(resourceName: "Dancer1")]],
        ["Wheel Pose" : [#imageLiteral(resourceName: "beyYoga2"), #imageLiteral(resourceName: "beyYoga2"), #imageLiteral(resourceName: "beyYoga2")]],
        ["Backbend" : [#imageLiteral(resourceName: "Backbend3"), #imageLiteral(resourceName: "Backbend2"), #imageLiteral(resourceName: "Backbend1")]]
    ]
    
    var userGoals = [[String:[(Double, UIImage)]?]?]()
    var journeyPosts = [Post?]()
    
    var asanaGoalImages: [UIImage]!
    var storedOffsets = [Int: CGFloat]()
    var userHasNewNotifications = false
    fileprivate var _refHandle: DatabaseHandle!
    var databaseReference: DatabaseReference!
    var newsfeedReference: DatabaseReference!
    var storageReference: StorageReference!
    var posts = [Post]()
    var currentLoggedInUser: User?
    var postedByUserId: String?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        getNewsfeedPostsFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.layoutSubviews()
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.YogieTheme.darkPrimaryColor.withAlphaComponent(0.75)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        newsfeedReference.removeAllObservers()
    }
    
    
    // MARK: Firebase Helper Methods
    
    func createUserFrom(_ uid: String, completion: @escaping (YogieUser) -> ())  {
        databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
        let usersRef = databaseReference.child("users")
        
        _refHandle = usersRef.observe(.childAdded, with: { (snapshot) in
            print("USERS SNAPSHOT: \(snapshot)")
            print("SNAPSHOT KEY: \(snapshot.key)")
            
            if snapshot.key == uid {
                if let userInfoDict = snapshot.value as? [String:Any] {
                    if let email = userInfoDict["email"] as? String {
                        if let username = userInfoDict["username"] as? String {
                            let user = YogieUser(email: email, username: username)
                            completion(user)
                        }
                    }
                }
            }
            
        })
    }
    
    func getPostImageFromStorage(_ key: String, completion: @escaping (UIImage) -> ()) {
        
        storageReference = Storage.storage().reference(forURL: "gs://yogie-ae904.appspot.com/").child("images/").child("\(key)")
        
        storageReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("ERROR DOWNLOADING IMAGE: \(error!.localizedDescription)")
                return
            }
            if let postImage = UIImage(data: data!) {
                completion(postImage)
            }
            }.resume()
    }
    
    var journeysContainerArr = [[(Double,UIImage)]]()
    
    func getNewsfeedPostsFromDatabase() {
        databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
        
        newsfeedReference = databaseReference.child("newsfeed")
        
        _refHandle = newsfeedReference.observe(.value, with: { (snapshot) in
            
            if let postMetadataDict = snapshot.value as? [String: Any] {
                for (key, value) in postMetadataDict {
                    self.getPostImageFromStorage(key, completion: { (image) in
                        if let postInfoDict = value as? [String:Any] {
                            if let userID = postInfoDict["postedBy"] as? String {
                                if let timestamp = postInfoDict["timestamp"] as? Double {
                                    if let type = postInfoDict["type"] as? String {
                                        self.createUserFrom(userID, completion: { (user) in
                                            let imageTimestampTuple = (timestamp, image)
                                            var imageTimestampTupleArr = [(Double,UIImage)]()
                                            imageTimestampTupleArr.append(imageTimestampTuple)
                                            
                                            switch type {
                                            case PostType.freebie.rawValue:
                                                let freebiePost = Post(type: type, imageData: imageTimestampTupleArr, user: user, timestamp: timestamp, asanaTitle: nil)
                                                self.userGoals.append(nil)
                                                
                                                self.posts.append(freebiePost)
                                            case PostType.journey.rawValue:
                                                if let asana = postInfoDict["asana"] as? String {
                                                    let journeyPost = Post(type: type, imageData: imageTimestampTupleArr, user: user, timestamp: timestamp, asanaTitle: asana)
                                                    var goalDict = [String:[(Double, UIImage)]?]()
                                                    goalDict["\(asana)"] = imageTimestampTupleArr
                                                    self.userGoals.append(goalDict)
                                                    
                                                    self.posts.append(journeyPost)
                                                }
                                            default:
                                                return
                                            }
                                            
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    func refreshData(_ sender: UIRefreshControl) {
        databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
        
        newsfeedReference = databaseReference.child("newsfeed")
        _refHandle = newsfeedReference.observe(.childAdded, with: { (snapshot) in
            
            if let postInfoDict = snapshot.value as? [String:Any] {
                self.posts = [Post]()
                self.userGoals = [[String:[(Double, UIImage)]?]?]()
              
                let imageStorageKey = snapshot.key
                self.getPostImageFromStorage(imageStorageKey, completion: { (image) in
                    if let userID = postInfoDict["postedBy"] as? String {
                        if let timestamp = postInfoDict["timestamp"] as? Double {
                            if let type = postInfoDict["type"] as? String {
                                self.createUserFrom(userID, completion: { (user) in
                                    
                                    let imageTimestampTuple = (timestamp, image)
                                    var imageTimestampTupleArr = [(Double,UIImage)]()
                                    imageTimestampTupleArr.append(imageTimestampTuple)
                                    
                                    switch type {
                                    case PostType.freebie.rawValue:
                                        let freebiePost = Post(type: type, imageData: imageTimestampTupleArr, user: user, timestamp: timestamp, asanaTitle: nil)
                                        self.userGoals.append(nil)
                                        
                                        self.posts.append(freebiePost)
                                    case PostType.journey.rawValue:
                                        if let asana = postInfoDict["asana"] as? String {
                                            let journeyPost = Post(type: type, imageData: imageTimestampTupleArr, user: user, timestamp: timestamp, asanaTitle: asana)
                                            var goalDict = [String:[(Double, UIImage)]?]()
                                            goalDict["\(asana)"] = imageTimestampTupleArr
                                            self.userGoals.append(goalDict)
                                            
                                            self.posts.append(journeyPost)
                                        }
                                    default:
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                })
                            }
                        }
                    }
                })
            }
        })
//         
        
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: Configuration Methods
    
    func configureTableView() {
        self.tableView.backgroundColor = UIColor.YogieTheme.darkPrimaryColor.withAlphaComponent(0.5)
        self.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.refreshControl?.tintColor = UIColor.YogieTheme.accentColor
    }
    
    func configureNavigationBar() {
        var notificationsIcon = UIImage(named: "bell_30x30")
        notificationsIcon = notificationsIcon?.withRenderingMode(.alwaysTemplate)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: notificationsIcon, style: .plain, target: self, action: #selector(showNotificationsActivityFeed(_:)))
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.YogieTheme.primaryColor //set to accentColor if there are new notifications (+ add red circle subview in top right corner); set to primaryColor if there are no new notifications
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Sacramento-Regular", size: 30)!
        ]
        self.navigationItem.title = "Haum"
    }
    
    // MARK: General Helper Methods
    
    func showNotificationsActivityFeed(_ sender: UIBarButtonItem) {
        userHasNewNotifications = false
        let notificationsFeed = NotificationsFeedViewController()
        let navVC = UINavigationController(rootViewController: notificationsFeed)
        
        self.present(navVC, animated: true, completion: nil)
    }
    
    func configureNewNotificationsIcon() {
        //If there are new notifications, change tint color to .accentColor and add red icon to top right corner
        //        //Setup Firebase listener for new notifications (in ViewDidLoad), if count > 1, newNotifications == true
        //        userHasNewNotifications = true
        //
        //        if userHasNewNotifications {
        //            let newNotificationDotIndicatorImage = UIImage(named: "red-dot-md")
        //
        //
        //
        //            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.YogieTheme.accentColor
        //        } else {
        //                    }
    }
    
    // MARK: Target Action Methods
    
    func toggleNamaskar(_ sender: UIButton) {
        if sender.backgroundColor == .white {
            namaskarOffered = true
            DispatchQueue.main.async {
                sender.backgroundColor = UIColor.YogieTheme.darkPrimaryColor
            }
        } else {
            namaskarOffered = false
            DispatchQueue.main.async {
                sender.backgroundColor = .white
            }
        }
    }
    
    // MARK: Lazy Instantiation
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightThin)
        label.textColor = UIColor.YogieTheme.accentColor
        label.textAlignment = .center
        return label
    }()
    
    // MARK: UICollection View Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let imageData = userGoals[collectionView.tag] else { return 1 }
        
        return imageData.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsfeedAsanaCVCell", for: indexPath) as! AsanaCollectionViewCell
        
        let imageDataDict = userGoals[collectionView.tag]
        if imageDataDict != nil {
            for (_, value) in imageDataDict! {
                if value != nil {
                    
                    let imageData = value![indexPath.item]
                    
                    item.asanaImageView.image = imageData.1
                    
                    let timeInterval = TimeInterval(imageData.0)
                    let dateFromTimeInterval = NSDate(timeIntervalSinceReferenceDate: timeInterval)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "M/d/yy"
                    let postDateString = dateFormatter.string(from: dateFromTimeInterval as Date)
                    
                    item.timestampLabel.text = postDateString
                    item.namaskarUpvoteButton.tag = indexPath.item
                    item.namaskarUpvoteButton.addTarget(self, action: #selector(toggleNamaskar(_:)), for: .touchUpInside)
                    
                    item.namaskarUpvoteButton.layer.cornerRadius = item.namaskarUpvoteButton.frame.size.width / 2
                    item.namaskarUpvoteButton.layer.masksToBounds = true
                    item.shareButton.layer.cornerRadius = item.shareButton.frame.size.width / 2
                    item.shareButton.layer.masksToBounds = true
                    item.commentButton.layer.cornerRadius = item.commentButton.frame.size.width / 2
                    item.commentButton.layer.masksToBounds = true                    
                }
            }
        }
        return item
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 428)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NewsfeedAsanaGoalTitleHeader", for: indexPath) as? AsanaGoalTitleCollectionReusableView
        
        var currentHeaderTitle = ""
        let imageDataDict = userGoals[collectionView.tag]
        if imageDataDict != nil {
            for (key, _) in imageDataDict! {
                currentHeaderTitle = key
            }
        }
        
        print("CURRENT JOURNEY TITLE: \(currentHeaderTitle)")
        return configureHeaderView(headerView!, with: "\(currentHeaderTitle)")
    }
    
    
    func configureHeaderView(_ headerView: UICollectionReusableView, with title: String) -> UICollectionReusableView {
        headerView.backgroundColor = UIColor.YogieTheme.darkPrimaryColor.withAlphaComponent(0.75)
        headerView.addSubview(headerLabel)
        headerLabel.text = "\(title) Journey"
        headerLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        
        let _ = [
            headerLabel.widthAnchor.constraint(equalTo: headerView.heightAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ].map {$0.isActive = true}
        return headerView
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let postsSortedByDate = self.posts.sorted() { $0.timestamp > $1.timestamp}
        return postsSortedByDate.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let postsSortedByDate = self.posts.sorted() { $0.timestamp > $1.timestamp}
        let post = postsSortedByDate[indexPath.row]
        
        if post.type == PostType.freebie.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsfeedCell", for: indexPath) as! NewsfeedTableViewCell
            
            cell.delegate = self
            cell.row = indexPath.row
            
            cell.namaskarUpvoteButton.tag = indexPath.row
            cell.namaskarUpvoteButton.addTarget(self, action: #selector(toggleNamaskar(_:)), for: .touchUpInside)
            cell.namaskarUpvoteButton.layer.cornerRadius = cell.namaskarUpvoteButton.frame.size.width / 2
            cell.namaskarUpvoteButton.layer.masksToBounds = true
            cell.shareButton.layer.cornerRadius = cell.shareButton.frame.size.width / 2
            cell.shareButton.layer.masksToBounds = true
            cell.commentButton.layer.cornerRadius = cell.commentButton.frame.size.width / 2
            cell.commentButton.layer.masksToBounds = true
            
            
            
            if let imageInfoTuple = post.imageData.first {
                
                cell.postImageView.image = imageInfoTuple.1
                
                let timeInterval = TimeInterval(imageInfoTuple.0)
                let dateFromTimeInterval = NSDate(timeIntervalSinceReferenceDate: timeInterval)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/d/yy h:mm a"
                let postDateString = dateFormatter.string(from: dateFromTimeInterval as Date)
                
                cell.timestampLabel.text = postDateString
            }
            return cell
        } else if post.type == PostType.journey.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsfeedUserAsanaGoalTVCell", for: indexPath) as! NewsfeedAsanaGoalTableViewCell
            
            cell.delegate = self
            cell.row = indexPath.row
            
            cell.usernameLabel.text = post.user.username
            
            
            if let imageInfoTuple = post.imageData.first {
                
                let timeInterval = TimeInterval(imageInfoTuple.0)
                let dateFromTimeInterval = NSDate(timeIntervalSinceReferenceDate: timeInterval)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/d/yy h:mm a"
                let postDateString = dateFormatter.string(from: dateFromTimeInterval as Date)
                
                cell.timestampLabel.text = postDateString
            }

            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 498
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let asanaTVC = cell as? NewsfeedAsanaGoalTableViewCell else { return }
        asanaTVC.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        asanaTVC.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let asanaTVC = cell as? NewsfeedAsanaGoalTableViewCell else { return }
        storedOffsets[indexPath.row] = asanaTVC.collectionViewOffset
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension NewsfeedTableViewController: NewsfeedCellProtocol {
    func segueToUserProfileFrom(row: Int) {
        let userProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileTVC") as! OtherUserProfileTableViewController
        
        self.present(userProfileVC, animated: true, completion: nil)
    }
    
    func toggleCommentsViewIn(row: Int) {
        print("Toggle Comments View")
    }
    
    func sharePostIn(row: Int) {
        print("Share post")
    }
}

extension NewsfeedTableViewController: NewsfeedAsanaGoalCellProtocol {
    
    func toggleCommentsViewInItem(row: Int) {
        print("Toggle Comments View")
    }
    
    func sharePostInItem(row: Int) {
        print("Share post")
    }
}
