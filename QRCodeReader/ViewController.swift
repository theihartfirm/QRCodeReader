//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Hardik Trivedi on 19/05/2016.
//  Copyright © 2016 TheiHartFirm. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{

    @IBOutlet weak var vwResult: UIView!
    @IBOutlet weak var lblQRCodeResult: UILabel!
    
    var objCaptureSession:AVCaptureSession?
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var vwQRCodeReader:UIView?
    
//    MARK: View Life Cycle Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initializeQRView()
    }
    
//    MARK: AVCaptureMetadataOutputObjectsDelegate Methods
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        if metadataObjects == nil || metadataObjects.count == 0 {
            
            vwQRCodeReader?.frame = CGRectZero
            lblQRCodeResult.text = "NO QRCode text detacted"
            
            return
        }
        
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            
            let objBarCode = objCaptureVideoPreviewLayer?.transformedMetadataObjectForMetadataObject(objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            vwQRCodeReader?.frame = objBarCode.bounds;
            
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                
                lblQRCodeResult.text = objMetadataMachineReadableCodeObject.stringValue
            }
        }
    }
    
//    MARK: Other Methods
    
    func configureVideoCapture()
    {
        let objCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSError?
        let objCaptureDeviceInput: AnyObject!
        
        do {
            
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            
            error = error1
            objCaptureDeviceInput = nil
        }
        
        if (error != nil) {
            
            let alert: UIAlertController = UIAlertController(title: "Error", message: "Your device not supported this appllication.", preferredStyle: .Alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        objCaptureSession = AVCaptureSession()
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    func addVideoPreviewLayer()
    {
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        objCaptureSession?.startRunning()
        
        self.view.bringSubviewToFront(vwResult)
    }
    
    
    func initializeQRView()
    {
        vwQRCodeReader = UIView()
        vwQRCodeReader?.layer.borderColor = UIColor.redColor().CGColor
        vwQRCodeReader?.layer.borderWidth = 5
        
        self.view.addSubview(vwQRCodeReader!)
        self.view.bringSubviewToFront(vwQRCodeReader!)
    }
    
}

