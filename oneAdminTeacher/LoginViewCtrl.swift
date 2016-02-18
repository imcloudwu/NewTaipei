import UIKit

class LoginViewCtrl: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var ProgressBar: UIProgressView!
    
    var progressTimer : ProgressTimer!
    
    var Timer : NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.title = "登入"
        
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
//        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        HttpClient.TrustServerList.insert(NotificationService.Domain)
        
        progressTimer = ProgressTimer(progressBar: ProgressBar)
        
        let reloadBtn =  UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "showLoginView")
        self.navigationItem.rightBarButtonItem = reloadBtn
        
        webView.delegate = self
        
        TryToLogin()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        showLoginView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func TryToLogin(){
        if let refreshToken = Keychain.load("refreshToken")?.stringValue{
            Keychain.delete("refreshToken")
            GotoNextViewByRefreshToken(refreshToken)
        }
    }
    
    func showLoginView(){
//        let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(Global.clientID)&response_type=code&state=redirect_uri%3A%2F&redirect_uri=http://＿blank&lang=zh-tw&scope=User.Mail,User.BasicInfo,1Campus.Notification.Read,1Campus.Notification.Send,*:sakura,*:ischool.teacher.app"
        
        //let scope = "User.Mail,User.BasicInfo,1Campus.Notification.Read,1Campus.Notification.Send,*:\(Global.ContractName)"
        
        //let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(Global.clientID)&response_type=code&state=http://_blank&redirect_uri=http://_blank&scope=\(scope)"
        
        let target = "https://auth.ntpc.edu.tw/oauth/authorize.php?response_type=code&client_id=44969e5df81a2f618497241db85a6e73&redirect_uri=http://localhost:3000/oauth/ntpc_callback&scope=User.Mail,User.BasicInfo,NTPC.Detial,:sakura&state="
        
        //let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(Global.clientID)&response_type=code&state=http://_blank&redirect_uri=http://_blank"
        
//        let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(Global.clientID)&response_type=code&state=http://_blank&redirect_uri=http://_blank&scope=User.Mail,User.BasicInfo,*:ischool.teacher.app"
        
        //載入登入頁面
        let urlobj = NSURL(string: target)
        let request = NSURLRequest(URL: urlobj!)
        webView.loadRequest(request)
    }
    
    func webViewDidStartLoad(webView: UIWebView){
        progressTimer.StartProgress()
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        progressTimer.StopProgress()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        
        progressTimer.StopProgress()
        
        //網路異常
        if let err = error where err.code == -1009{
            
            if let code = GetCodeFromError(err){
                GotoNextViewByCode(code)
            }
            else{
                let alert = UIAlertController(title: "網路無法連線", message: "請點選右上方的重新整理", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        //取得code
        if let err = error where err.domain == "NSURLErrorDomain" && err.code == -1004{
            
            if let code = GetCodeFromError(err){
                GotoNextViewByCode(code)
            }
        }
    }
    
    func GetCodeFromError(error: NSError) -> String?{
        if let url = error.userInfo["NSErrorFailingURLStringKey"] as? String{
            if let range = url.rangeOfString("http://localhost:3000/oauth/ntpc_callback?state=&code="){
                var code = url
                code.removeRange(range)
                
                //println(code)
                
                return code
            }
        }
        
        return nil
    }
    
    func GotoNextViewByCode(code:String){
        
        UpdateLocalPhotoFile()
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("prepareViewCtrl") as! PrepareViewCtrl
        nextView.code = code
        ChangeContentView(nextView)
        //self.presentViewController(nextView, animated: true, completion: nil)
    }
    
    func GotoNextViewByRefreshToken(refreshToken:String){
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("prepareViewCtrl") as! PrepareViewCtrl
        nextView.refreshToken = refreshToken
        ChangeContentView(nextView)
    }
    
    func UpdateLocalPhotoFile(){
        
        var rsp : NSData?
        
        do{
            rsp = try HttpClient.Get("https://auth.ntpc.edu.tw/service/getpic.php")
        }
        catch _{
            rsp = nil
        }
        
        if let data = rsp{
            
            let image = UIImage(data: data)
            
            let path = Global.MyPhotoLocalPath
            
            let imgData = UIImageJPEGRepresentation(image!, 0.5)
            
            imgData?.writeToFile(path, atomically: true)
        }
    }
}







