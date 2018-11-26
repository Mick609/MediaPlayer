//
//  ViewController.swift
//  MediaPlayer
//
//  Created by Mick Shi on 19/11/18.
//  Copyright © 2018 Mick Shi. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AVFoundation
import Charts

class ViewController: NSViewController {
    
    @IBOutlet weak var playerView1: AVPlayerView!
    @IBOutlet weak var playerView2: AVPlayerView!
    
    @IBOutlet weak var rootAddrText: NSTextField!
    
    @IBOutlet weak var videoText1: NSTextField!
    @IBOutlet weak var videoText2: NSTextField!
    
    var player1: AVPlayer?
    var player2: AVPlayer?
    
    var rootAddr = ""
    var videoAddr1 = ""
    var videoAddr2 = ""
    var videoFile1: URL?
    var videoFile2: URL?
    let fileManager = FileManager.default
    
    var timeZero = Date.init(timeIntervalSince1970: 0)
    var timeVideo1 = Date.init(timeIntervalSince1970: 0)
    var timeVideo2 = Date.init(timeIntervalSince1970: 0)
    var timeDevice1 = Date.init(timeIntervalSince1970: 0)
    var timeDevice2 = Date.init(timeIntervalSince1970: 0)
    var timeDevice3 = Date.init(timeIntervalSince1970: 0)
    var timeDevice4 = Date.init(timeIntervalSince1970: 0)
    
    var timer = Timer()
    
    //    time interval between each data entry is 10ms, we want to display total 5s of data, thus we need 500 of dataEntry
    var dataEntrySize = 500
    //    a LineChartDataSet is a line in a chart, each chart has 8 variables, thus 8 lines, we have four charts. So allDataEntries.count == 4, allDataEntries[0].count == 8
    var allData = [[[Int]]](repeating: [[0]], count: 4)
    
    @IBOutlet weak var lineChart1: LineChartView!
    @IBOutlet weak var lineChart2: LineChartView!
    @IBOutlet weak var lineChart3: LineChartView!
    @IBOutlet weak var lineChart4: LineChartView!
    
    var currentDataIndex1 = 0
    var currentDataIndex2 = 0
    var currentDataIndex3 = 0
    var currentDataIndex4 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Start the application")
        
    }
    @IBAction func loadRoot(_ sender: Any) {
        rootAddr = rootAddrText.stringValue
        if ifFileExists(fileAddr: URL(fileURLWithPath: rootAddr)){
            if ifFileExists(fileAddr: URL(fileURLWithPath: rootAddr + "/Camera1")){
                let files = getFilesInDir(dirAddr: URL(fileURLWithPath: rootAddr + "/Camera1" ))!;
                for file in files{
                    if file.pathExtension == "mp4"{
                        videoFile1 = file
                    }
                }
            }
            if ifFileExists(fileAddr: URL(fileURLWithPath: rootAddr + "/Camera2")){
                let files = getFilesInDir(dirAddr: URL(fileURLWithPath: rootAddr + "/Camera2" ))!;
                for file in files{
                    if file.pathExtension == "mp4"{
                        videoFile2 = file
                    }
                }
            }
            videoText1.stringValue = videoFile1!.absoluteString
            videoText2.stringValue = videoFile2!.absoluteString
            
            var timeStrings = videoFile1!.absoluteString.split(separator: "/")
            var timeString = timeStrings[timeStrings.count - 1]
            timeStrings = timeString.split(separator: ".")
            timeString = timeStrings[timeStrings.count - 2]
            var dateString = timeStrings[timeStrings.count - 3]
            timeStrings = timeString.split(separator: "-")
            var dateStrings = dateString.split(separator: "-")
            timeVideo1 = setDate(year: String(dateStrings[0]),
                                 month: String(dateStrings[1]),
                                 day: String(dateStrings[2]),
                                 hour: String(timeStrings[0]),
                                 min: String(timeStrings[1]),
                                 sec: String(timeStrings[2]),
                                 milliSec: String(timeStrings[3]))
            
            timeStrings = videoFile2!.absoluteString.split(separator: "/")
            timeString = timeStrings[timeStrings.count - 1]
            timeStrings = timeString.split(separator: ".")
            timeString = timeStrings[timeStrings.count - 2]
            dateString = timeStrings[timeStrings.count - 3]
            timeStrings = timeString.split(separator: "-")
            dateStrings = dateString.split(separator: "-")
            timeVideo2 = setDate(year: String(dateStrings[0]),
                                 month: String(dateStrings[1]),
                                 day: String(dateStrings[2]),
                                 hour: String(timeStrings[0]),
                                 min: String(timeStrings[1]),
                                 sec: String(timeStrings[2]),
                                 milliSec: String(timeStrings[3]))
            
            if ifFileExists(fileAddr: URL(fileURLWithPath: rootAddr + "/UWB")){
                let files = getFilesInDir(dirAddr: URL(fileURLWithPath: rootAddr + "/UWB" ))!;
                for file in files {
                    let sensorFileDirs = getFilesInDir(dirAddr: file)!;
                    for sensorFileDir in sensorFileDirs {
                        setChart(sensorFileDir: sensorFileDir)
                    }
                }
            }
        }else {
            return
        }
        
        player1 = AVPlayer(url: videoFile1!)
        player2 = AVPlayer(url: videoFile2!)
        
        playerView1.player = player1
        playerView2.player = player2
        
        setTimeZero()
        print(timeZero)
    }
    @IBAction func play(_ sender: Any) {
        print ("play")
        player1!.play()
        player2!.play()
        pauseResumeChartPlay(isPlaying: true)
    }
    
    @IBAction func reset(_ sender: Any) {
        print ("reset")
        actionPause()
        playVideoFromTimeZero(player: player1!)
        playVideoFromTimeZero(player: player2!)
        setChartsToTimeZero()
        pauseResumeChartPlay(isPlaying: true)
    }
    @IBAction func pause(_ sender: Any) {
        print ("pause")
        actionPause()
    }
    func actionPause(){
        player1!.pause()
        player2!.pause()
        pauseResumeChartPlay(isPlaying: false)
    }
    @IBAction func rewind(_ sender: Any) {
        print ("rewind")
        player1?.seek(to: getDestinateRewindTime(time: -5, player: player1!))
        player2?.seek(to: getDestinateRewindTime(time: -5, player: player2!))
        
        currentDataIndex1 -= 300
        currentDataIndex2 -= 300
        currentDataIndex3 -= 300
        currentDataIndex4 -= 300
        
        setChartDataFromIndex(index: currentDataIndex1, currentChart: lineChart1)
        setChartDataFromIndex(index: currentDataIndex2, currentChart: lineChart2)
        setChartDataFromIndex(index: currentDataIndex3, currentChart: lineChart3)
        setChartDataFromIndex(index: currentDataIndex4, currentChart: lineChart4)
    }
    @IBAction func forward(_ sender: Any) {
        print ("forward")
        
        player1?.seek(to: getDestinateRewindTime(time: +5, player: player1!))
        player2?.seek(to: getDestinateRewindTime(time: +5, player: player2!))
        
        currentDataIndex1 += 300
        currentDataIndex2 += 300
        currentDataIndex3 += 300
        currentDataIndex4 += 300
        
        setChartDataFromIndex(index: currentDataIndex1, currentChart: lineChart1)
        setChartDataFromIndex(index: currentDataIndex2, currentChart: lineChart2)
        setChartDataFromIndex(index: currentDataIndex3, currentChart: lineChart3)
        setChartDataFromIndex(index: currentDataIndex4, currentChart: lineChart4)
    }
    func playVideoFromTimeZero(player: AVPlayer){
        var offset = 0.0
        if player == player1{
            offset = timeZero.timeIntervalSince(timeVideo1)
        }else if player == player2 {
            offset = timeZero.timeIntervalSince(timeVideo2)
        }
        print(offset)
        seekToSecond(player: player, sec: offset + 3)
        player.play()
    }
    func setChartsToTimeZero(){
        var offset1 = 0
        var offset2 = 0
        var offset3 = 0
        var offset4 = 0
        print(timeZero.timeIntervalSince(timeDevice1))
        print(timeZero.timeIntervalSince(timeDevice2))
        print(timeZero.timeIntervalSince(timeDevice3))
        print(timeZero.timeIntervalSince(timeDevice4))
        offset1 = Int(timeZero.timeIntervalSince(timeDevice1) * 100.0)
        offset2 = Int(timeZero.timeIntervalSince(timeDevice2) * 100.0)
        offset3 = Int(timeZero.timeIntervalSince(timeDevice3) * 100.0)
        offset4 = Int(timeZero.timeIntervalSince(timeDevice4) * 100.0)
        
        currentDataIndex1 = offset1
        currentDataIndex2 = offset2
        currentDataIndex3 = offset3
        currentDataIndex4 = offset4
        
        setChartDataFromIndex(index: currentDataIndex1, currentChart: lineChart1)
        setChartDataFromIndex(index: currentDataIndex2, currentChart: lineChart2)
        setChartDataFromIndex(index: currentDataIndex3, currentChart: lineChart3)
        setChartDataFromIndex(index: currentDataIndex4, currentChart: lineChart4)
    }
    func getDestinateRewindTime(time: Int, player: AVPlayer) -> CMTime{
        var newValue = CMTimeGetSeconds(player.currentTime())
        newValue = newValue + Double(time)
        if newValue < 0
        {
            newValue = 0
        }
        let desTime = CMTimeMakeWithSeconds( Double(newValue), preferredTimescale: 100000)
        return desTime
    }
    
    func seekToSecond(player: AVPlayer, sec:Double){
        player.seek(to: CMTimeMakeWithSeconds( Double(sec), preferredTimescale: 100000))
    }
    
    func ifFileExists(fileAddr: URL) ->Bool{
        if fileManager.fileExists(atPath: fileAddr.path) {
            return true
        } else {
            return false
        }
    }
    func getFilesInDir(dirAddr: URL) ->[URL]?{
        do {
            let Dirfiles = try fileManager.contentsOfDirectory(at:dirAddr, includingPropertiesForKeys: nil)
            // process files
            let files = getRidOfDSStore(files: Dirfiles)
            return files
        }catch{
            print("Error while enumerating files \(dirAddr): \(error.localizedDescription)")
        }
        return nil
    }
    func getRidOfDSStore(files: [URL]) -> [URL]{
        var result = [URL]()
        for file in files {
            let dirName = file.absoluteString.split(separator: "/")
            if dirName[dirName.count - 1] != ".DS_Store"{
                result.append(file)
            }
        }
        return result
    }
    func setDate(year: String, month: String, day:String, hour:String, min: String, sec: String, milliSec: String) -> Date{
        var dateComponents = DateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        dateComponents.timeZone = TimeZone(abbreviation: "SGT")
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(min)
        dateComponents.second = Int(sec)
        dateComponents.nanosecond = Int(milliSec)! * 1000000
        let userCalendar = Calendar.current
        let date = userCalendar.date(from: dateComponents)!
        return date
    }
    
    func setChart(sensorFileDir: URL){
        var timestamps = [Int]()
        var accX = [Int]()
        var accY = [Int]()
        var accZ = [Int]()
        var gyroX = [Int]()
        var gyroY = [Int]()
        var gyroZ = [Int]()
        var distanceX1 = [Int]()
        var distanceX2 = [Int]()
        //        init variables from file
        var currentChart = lineChart1
        
        var dummyDate = Date.init(timeIntervalSince1970: 0)
        let files = getFilesInDir(dirAddr: sensorFileDir)
        for file in files! {
            let dirName = file.absoluteString.split(separator: "/")
            let fileName = dirName[dirName.count - 1]
            let texts = fileName.split(separator: "_")
            let dataType = texts[0]
            if dataType == "RawData"{
                //reading the file
                do {
                    let text = try String(contentsOf: file, encoding: .utf8)
                    var lines = text.split(separator: "\n")
                    if lines.count == 1{
                        lines = text.split(separator: "\r\n")
                    }
                    for line in lines{
                        let variables = line.split(separator: ",")
                        if variables.count > 8{
                            timestamps.append(Int(variables[0])!)
                            accX.append(Int(variables[1])!)
                            accY.append(Int(variables[2])!)
                            accZ.append(Int(variables[3])!)
                            gyroX.append(Int(variables[4])!)
                            gyroY.append(Int(variables[5])!)
                            gyroZ.append(Int(variables[6])!)
                            distanceX1.append(Int(variables[7])!)
                            distanceX2.append(Int(variables[8])!)
                        }
                    }
                }
                catch {
                    print("Error when reading the file " + file.absoluteString)}
                
                dummyDate = timeVideo1
                let addSecond:TimeInterval = Double(timestamps[0] / 1000)
                dummyDate = dummyDate.addingTimeInterval(addSecond)
            }
        }
        
        let dirName = sensorFileDir.absoluteString.split(separator: "/")
        let fileName = dirName[dirName.count - 1]
        let deviceNames = fileName.split(separator: "-")
        let deviceName = deviceNames[deviceNames.count - 1]
        
        if deviceName == "GMSv6_U1"{
            allData[0] = [timestamps, accX, accY, accZ, gyroX, gyroY, gyroZ, distanceX1, distanceX2]
            timeDevice1 = dummyDate
            currentChart = lineChart1
            currentChart!.chartDescription?.text = "GMSv6_U1"
        }else if deviceName == "GMSv6_U2"{
            allData[1] = [timestamps, accX, accY, accZ, gyroX, gyroY, gyroZ, distanceX1, distanceX2]
            timeDevice2 = dummyDate
            currentChart = lineChart2
            currentChart!.chartDescription?.text = "GMSv6_U2"
        }else if deviceName == "GMSv6_U3"{
            allData[2] = [timestamps, accX, accY, accZ, gyroX, gyroY, gyroZ, distanceX1, distanceX2]
            timeDevice3 = dummyDate
            currentChart = lineChart3
            currentChart!.chartDescription?.text = "GMSv6_U3"
        }else if deviceName == "GMSv6_U4"{
            allData[3] = [timestamps, accX, accY, accZ, gyroX, gyroY, gyroZ, distanceX1, distanceX2]
            print()
            timeDevice4 = dummyDate
            currentChart = lineChart4
            currentChart!.chartDescription?.text = "GMSv6_U4"
        }else {
            return
        }
        var lineChartEntryAccX = [ChartDataEntry]()
        var lineChartEntryAccY = [ChartDataEntry]()
        var lineChartEntryAccZ = [ChartDataEntry]()
        
        var lineChartEntryGyroX = [ChartDataEntry]()
        var lineChartEntryGyroY = [ChartDataEntry]()
        var lineChartEntryGyroZ = [ChartDataEntry]()
        
        var lineChartEntryDistanceX1 = [ChartDataEntry]()
        var lineChartEntryDistanceX2 = [ChartDataEntry]()
        for i in 0..<dataEntrySize {
            lineChartEntryAccX.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( accX[i])))
            lineChartEntryAccY.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( accY[i])))
            lineChartEntryAccZ.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( accZ[i])))
            
            lineChartEntryGyroX.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( gyroX[i])))
            lineChartEntryGyroY.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( gyroY[i])))
            lineChartEntryGyroZ.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( gyroZ[i])))
            
            lineChartEntryDistanceX1.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( distanceX1[i])))
            lineChartEntryDistanceX2.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( distanceX2[i])))
        }
        let line1 = LineChartDataSet(values: lineChartEntryAccX, label: "accX")
        line1.colors = [NSUIColor.red]
        line1.drawCirclesEnabled = false
        
        let line2 = LineChartDataSet(values: lineChartEntryAccY, label: "accY")
        line2.colors = [NSUIColor.yellow]
        line2.drawCirclesEnabled = false
        
        let line3 = LineChartDataSet(values: lineChartEntryAccZ, label: "accZ")
        line3.colors = [NSUIColor.brown]
        line3.drawCirclesEnabled = false
        
        let line4 = LineChartDataSet(values: lineChartEntryGyroX, label: "gyroX")
        line4.colors = [NSUIColor.green]
        line4.drawCirclesEnabled = false
        
        let line5 = LineChartDataSet(values: lineChartEntryGyroY, label: "gyroY")
        line5.colors = [NSUIColor.gray]
        line5.drawCirclesEnabled = false
        
        let line6 = LineChartDataSet(values: lineChartEntryGyroZ, label: "gyroZ")
        line6.colors = [NSUIColor.blue]
        line6.drawCirclesEnabled = false
        
        let line7 = LineChartDataSet(values: lineChartEntryDistanceX1, label: "distanceX1")
        line7.colors = [NSUIColor.purple]
        line7.drawCirclesEnabled = false
        
        let line8 = LineChartDataSet(values: lineChartEntryDistanceX1, label: "distanceX2")
        line8.colors = [NSUIColor.black]
        line8.drawCirclesEnabled = false
        
        let data = LineChartData()
        data.addDataSet(line1)
        data.addDataSet(line2)
        data.addDataSet(line3)
        data.addDataSet(line4)
        data.addDataSet(line5)
        data.addDataSet(line6)
        data.addDataSet(line7)
        data.addDataSet(line8)
        currentChart!.data = data
        currentChart!.gridBackgroundColor = NSUIColor.black
        currentChart!.backgroundColor = NSUIColor.white
    }
    func setChartDataFromIndex(index: Int, currentChart: LineChartView){
        
        
        var sensorData = [[Int]]()
        if currentChart == lineChart1{
            sensorData = allData[0]
            currentDataIndex1 = index
        }else if currentChart == lineChart2{
            sensorData = allData[1]
            currentDataIndex2 = index
        }else if currentChart == lineChart3{
            sensorData = allData[2]
            currentDataIndex3 = index
        }else if currentChart == lineChart4{
            sensorData = allData[3]
            currentDataIndex4 = index
        }
        
        var timestamps = sensorData[0]
        var accX = sensorData[1]
        var accY =  sensorData[2]
        var accZ = sensorData[3]
        var gyroX = sensorData[4]
        var gyroY =  sensorData[5]
        var gyroZ =  sensorData[6]
        var distanceX1 =  sensorData[7]
        var distanceX2 =  sensorData[8]
        
        var lineChartEntryAccX = [ChartDataEntry]()
        var lineChartEntryAccY = [ChartDataEntry]()
        var lineChartEntryAccZ = [ChartDataEntry]()
        
        var lineChartEntryGyroX = [ChartDataEntry]()
        var lineChartEntryGyroY = [ChartDataEntry]()
        var lineChartEntryGyroZ = [ChartDataEntry]()
        
        var lineChartEntryDistanceX1 = [ChartDataEntry]()
        var lineChartEntryDistanceX2 = [ChartDataEntry]()
        if index+dataEntrySize<timestamps.count{
            for i in index..<index+dataEntrySize {
                lineChartEntryAccX.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( accX[i])))
                lineChartEntryAccY.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( accY[i])))
                lineChartEntryAccZ.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( accZ[i])))
                
                lineChartEntryGyroX.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( gyroX[i])))
                lineChartEntryGyroY.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( gyroY[i])))
                lineChartEntryGyroZ.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( gyroZ[i])))
                
                lineChartEntryDistanceX1.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( distanceX1[i])))
                lineChartEntryDistanceX2.append(ChartDataEntry(x: Double(timestamps[i]), y:Double( distanceX2[i])))
            }
            let line1 = LineChartDataSet(values: lineChartEntryAccX, label: "accX")
            line1.colors = [NSUIColor.red]
            line1.drawCirclesEnabled = false
            
            let line2 = LineChartDataSet(values: lineChartEntryAccY, label: "accY")
            line2.colors = [NSUIColor.yellow]
            line2.drawCirclesEnabled = false
            
            let line3 = LineChartDataSet(values: lineChartEntryAccZ, label: "accZ")
            line3.colors = [NSUIColor.brown]
            line3.drawCirclesEnabled = false
            
            let line4 = LineChartDataSet(values: lineChartEntryGyroX, label: "gyroX")
            line4.colors = [NSUIColor.green]
            line4.drawCirclesEnabled = false
            
            let line5 = LineChartDataSet(values: lineChartEntryGyroY, label: "gyroY")
            line5.colors = [NSUIColor.gray]
            line5.drawCirclesEnabled = false
            
            let line6 = LineChartDataSet(values: lineChartEntryGyroZ, label: "gyroZ")
            line6.colors = [NSUIColor.blue]
            line6.drawCirclesEnabled = false
            
            let line7 = LineChartDataSet(values: lineChartEntryDistanceX1, label: "distanceX1")
            line7.colors = [NSUIColor.purple]
            line7.drawCirclesEnabled = false
            
            let line8 = LineChartDataSet(values: lineChartEntryDistanceX1, label: "distanceX2")
            line8.colors = [NSUIColor.black]
            line8.drawCirclesEnabled = false
            
            let data = LineChartData()
            data.addDataSet(line1)
            data.addDataSet(line2)
            data.addDataSet(line3)
            data.addDataSet(line4)
            data.addDataSet(line5)
            data.addDataSet(line6)
            data.addDataSet(line7)
            data.addDataSet(line8)
            currentChart.data = data
            currentChart.notifyDataSetChanged()// let the chart know it's data changed
            currentChart.invalidateRestorableState()
        }}
    
    
    func forwardChartForIndexCount(indexCount: Int, currentChart: LineChartView){
        var oldIndex = 0
        var currentIndex = 0
        var sensorData = [[Int]]()
        if currentChart == lineChart1{
            sensorData = allData[0]
            oldIndex = currentDataIndex1
            currentDataIndex1 += indexCount
            currentIndex = currentDataIndex1
        }else if currentChart == lineChart2{
            sensorData = allData[1]
            oldIndex = currentDataIndex2
            currentDataIndex2 += indexCount
            currentIndex = currentDataIndex2
        }else if currentChart == lineChart3{
            sensorData = allData[2]
            oldIndex = currentDataIndex3
            currentDataIndex3 += indexCount
            currentIndex = currentDataIndex3
        }else if currentChart == lineChart4{
            sensorData = allData[3]
            oldIndex = currentDataIndex4
            currentDataIndex4 += indexCount
            currentIndex = currentDataIndex4
        }
        print( currentChart.chartDescription!.text! + ": " + String(oldIndex)+","+String(currentIndex))
        var timestamps = sensorData[0]
        var accX = sensorData[1]
        var accY =  sensorData[2]
        var accZ = sensorData[3]
        var gyroX = sensorData[4]
        var gyroY =  sensorData[5]
        var gyroZ =  sensorData[6]
        var distanceX1 =  sensorData[7]
        var distanceX2 =  sensorData[8]
        if currentIndex+dataEntrySize<timestamps.count{
            for i in 0..<indexCount {
                //                currentChart.data?.getDataSetByIndex(0)?.removeFirst()
                //                currentChart.data?.getDataSetByIndex(1)?.removeFirst()
                //                currentChart.data?.getDataSetByIndex(2)?.removeFirst()
                //                currentChart.data?.getDataSetByIndex(3)?.removeFirst()
                //                currentChart.data?.getDataSetByIndex(4)?.removeFirst()
                //                currentChart.data?.getDataSetByIndex(5)?.removeFirst()
                //                currentChart.data?.getDataSetByIndex(6)?.removeFirst()
                //                currentChart.data?.getDataSetByIndex(7)?.removeFirst()
                
                currentChart.data?.getDataSetByIndex(0)?.addEntry(ChartDataEntry(x: Double(timestamps[oldIndex+i+1]), y:Double( accX[oldIndex+i+1])))
                currentChart.data?.getDataSetByIndex(1)?.addEntry(ChartDataEntry(x: Double(timestamps[oldIndex+i+1]), y:Double( accY[oldIndex+i+1])))
                currentChart.data?.getDataSetByIndex(2)?.addEntry(ChartDataEntry(x: Double(timestamps[oldIndex+i+1]), y:Double( accZ[oldIndex+i+1])))
                currentChart.data?.getDataSetByIndex(3)?.addEntry(ChartDataEntry(x: Double(timestamps[oldIndex+i+1]), y:Double( gyroX[oldIndex+i+1])))
                currentChart.data?.getDataSetByIndex(4)?.addEntry(ChartDataEntry(x: Double(timestamps[oldIndex+i+1]), y:Double( gyroY[oldIndex+i+1])))
                currentChart.data?.getDataSetByIndex(5)?.addEntry(ChartDataEntry(x: Double(timestamps[oldIndex+i+1]), y:Double( gyroZ[oldIndex+i+1])))
                currentChart.data?.getDataSetByIndex(6)?.addEntry(ChartDataEntry(x: Double(timestamps[oldIndex+i+1]), y:Double( distanceX1[oldIndex+i+1])))
                currentChart.data?.getDataSetByIndex(7)?.addEntry(ChartDataEntry(x: Double(timestamps[oldIndex+i+1]), y:Double( distanceX2[oldIndex+i+1])))
            }
            
            currentChart.notifyDataSetChanged()// let the chart know it's data changed
            currentChart.invalidateRestorableState()
        }
    }
    func pauseResumeChartPlay(isPlaying: Bool){
        if isPlaying{
            print("Start Timer")
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateChart), userInfo: nil, repeats: true)
            
        }
        else{
            print("Stop Timer")
            self.timer.invalidate()
        }
    }
    @objc func updateChart(){
        self.currentDataIndex1 += 100
        self.currentDataIndex2 += 100
        self.currentDataIndex3 += 100
        self.currentDataIndex4 += 100
        
        self.setChartDataFromIndex(index:  self.currentDataIndex1, currentChart:  self.lineChart1)
        self.setChartDataFromIndex(index:  self.currentDataIndex2, currentChart:  self.lineChart2)
        self.setChartDataFromIndex(index:  self.currentDataIndex3, currentChart:  self.lineChart3)
        self.setChartDataFromIndex(index:  self.currentDataIndex4, currentChart:  self.lineChart4)
        
        //        forwardChartForIndexCount(indexCount: 100, currentChart: lineChart1)
        //        forwardChartForIndexCount(indexCount: 100, currentChart: lineChart2)
        //        forwardChartForIndexCount(indexCount: 100, currentChart: lineChart3)
        //        forwardChartForIndexCount(indexCount: 100, currentChart: lineChart4)
    }
    func setTimeZero(){
        if timeZero < timeVideo1 {
            timeZero = timeVideo1
        }
        if timeZero < timeVideo2 {
            timeZero = timeVideo2
        }
        if timeZero < timeDevice1 {
            timeZero = timeDevice1
        }
        if timeZero < timeDevice2 {
            timeZero = timeDevice2
        }
        if timeZero < timeDevice3 {
            timeZero = timeDevice3
        }
        if timeZero < timeDevice4 {
            timeZero = timeDevice4
        }
    }
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    override open func viewWillAppear()
    {
        self.lineChart1.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
}
