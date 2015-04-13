//
//  ViewController.swift
//  BandCustomPagesSwift
//
//  Created by Mark Thistle on 4/9/15.
//  Copyright (c) 2015 New Thistle LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MSBClientManagerDelegate {
    
    @IBOutlet weak var txtOutput: UITextView!
    @IBOutlet weak var accelLabel: UILabel!
    weak var client: MSBClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MSBClientManager.sharedManager().delegate = self
        if let client = MSBClientManager.sharedManager().attachedClients().first as? MSBClient {
            self.client = client
            MSBClientManager.sharedManager().connectClient(self.client)
            self.output("Please wait. Connecting to Band...")
        } else {
            self.output("Failed! No Bands attached.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func runExampleCode(sender: AnyObject) {
        if let client = self.client {
            if client.isDeviceConnected == false {
                self.output("Band is not connected. Please wait....")
                return
            }
            self.output("Creating tile...")
            let tileName = "A tile"
            let tileIcon = MSBIcon(UIImage: UIImage(named: "A.png"), error: nil)
            let smallIcon = MSBIcon(UIImage: UIImage(named: "Aa.png"), error: nil)
            let tileID = NSUUID(UUIDString: "CABDBA9F-12FD-47A5-83A9-E7270A43BB99")
            var tile = MSBTile(id: tileID, name: tileName, tileIcon: tileIcon, smallIcon: smallIcon, error: nil)
            
            var textBlock = MSBTextBlock(rect: MSBRect.rectwithX(0, y: 0, width: 230, height: 40), font: MSBTextBlockFont.Small, baseline: 25)
            textBlock.elementId = 10
            textBlock.horizontalAlignment = MSBPageElementHorizontalAlignment.Left
            textBlock.baselineAlignment = MSBTextBlockBaselineAlignment.Absolute
            textBlock.color = MSBColor(red: 0xff, green: 0xff, blue: 0xff)
            
            var barcode = MSBBarcode(rect: MSBRect.rectwithX(0, y: 5, width: 230, height: 95), barcodeType: MSBBarcodeType.CODE39)
            barcode.elementId = 11
            barcode.color = MSBColor(red: 0xff, green: 0xff, blue: 0xff)
            
            var flowList = MSBFlowList(rect: MSBRect.rectwithX(15, y: 0, width: 260, height: 105), orientation: MSBFlowListOrientation.Vertical)
            flowList.margins = MSBMargins(left: 0, top: 0, right: 0, bottom: 0)
            flowList.color = nil
            flowList.children.addObject(textBlock)
            flowList.children.addObject(barcode)
            
            var page = MSBPageLayout()
            page.root = flowList
            tile.pageLayouts.addObject(page)
            
            client.tileManager.addTile(tile, completionHandler: { (error: NSError!) in
                if error == nil || MSBNSErrorCodes(rawValue: error.code) == MSBNSErrorCodes.MSBErrorCodeTileAlreadyExist {
                    self.output("Creating page...")
                    
                    var pageID = NSUUID(UUIDString: "CAB4BA9F-12FD-47A5-83A9-E7270A43BB99")
                    var pageValues = [MSBPageBarcodeCode39Data(elementId: 11, value: "A1 B", error: nil),
                                      MSBPageTextData(elementId: 10, text: "Barcode value: A1 B", error: nil)]
                    var page = MSBPageData(id: pageID, templateIndex: 0, value: pageValues)
                    
                    client.tileManager.setPages([page], tileId: tile.tileId, completionHandler: { (error: NSError!) in
                        if error != nil {
                            self.output("Successfully Finished!!! You can remove tile via Microsoft Health App.")
                        }
                    })
                } else {
                    self.output(error.localizedDescription)
                }
            })
        } else {
            self.output("Band is not connected. Please wait....")
        }
    }
    
    func output(message: String) {
        self.txtOutput.text = NSString(format: "%@\n%@", self.txtOutput.text, message) as String
        let p = self.txtOutput.contentOffset
        self.txtOutput.setContentOffset(p, animated: false)
        self.txtOutput.scrollRangeToVisible(NSMakeRange(self.txtOutput.text.lengthOfBytesUsingEncoding(NSASCIIStringEncoding), 0))
    }
    
    // Mark - Client Manager Delegates
    func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        self.output("Band connected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        self.output(")Band disconnected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        self.output("Failed to connect to Band.")
        self.output(error.description)
    }
}

