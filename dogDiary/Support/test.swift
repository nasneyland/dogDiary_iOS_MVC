//
//  test.swift
//  dogDiary
//
//  Created by najin on 2021/03/26.
//

import UIKit
import Charts

class BodyChartViewController: UIViewController,ChartViewDelegate, IAxisValueFormatter {

//    @IBOutlet weak var Height: UITextView!
//    @IBOutlet weak var NowWeight: UITextView!
//    @IBOutlet weak var RecordButton: UIButton!
    @IBOutlet weak var Chart: LineChartView!
//    @IBOutlet weak var Label: UILabel!
//
//    var HeightTmpString : String = ""
//    var NowWeightTmpString : String = ""
//
//    var Data : Array<Array<String>> = []
    var Dates : Array<String> = []
    var Weights : Array<Double> = []
    var yVals1 : [ChartDataEntry]?

    

    weak var axisFormatDelegate: IAxisValueFormatter?
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return ""
    }

//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//
//            let date = Date(timeIntervalSince1970: value)
//
//           let formatter = DateFormatter()
//
//           formatter.dateFormat = "yyyy-MM-dd"
//
//           formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
//
//           return formatter.string(from: date)
//
//    }

    override func viewDidLoad() {

        super.viewDidLoad()
        self.axisFormatDelegate = self

        setupChart()
   }


    

//    func get_date(inputdatestring : String) -> String{
//
//        var date = ""
//
//        for i in inputdatestring{
//
//            if i != "-"{
//
//                date.append(i)
//
//            }
//
//        }
//
//        return date
//
//    }

    
    func setupChart(){
       //self.Chart.descriptionText = "Speed"
        //self.Chart.descriptionTextColor = UIColor.black
        self.Chart.gridBackgroundColor = UIColor.darkGray
        self.Chart.noDataText = "데이터가 없습니다"
        self.Chart.rightAxis.enabled = false
        self.Chart.drawGridBackgroundEnabled = false
        self.Chart.doubleTapToZoomEnabled = false
        self.Chart.xAxis.drawGridLinesEnabled = false
        self.Chart.xAxis.drawAxisLineEnabled = false
        self.Chart.rightAxis.drawGridLinesEnabled = false
        self.Chart.rightAxis.drawAxisLineEnabled = false
        self.Chart.leftAxis.drawGridLinesEnabled = false
        self.Chart.leftAxis.drawAxisLineEnabled = false
        self.Chart.xAxis.labelFont = UIFont.systemFont(ofSize: 5)
        self.Chart.backgroundColor = UIColor.white
        self.Chart.animate(yAxisDuration: 0.1)
        //self.Chart.xAxis.valueFormatter = XAxisValueFormatter as IAxisValueFormatter
        setChartData(xValsArr: self.Dates, yValsArr: self.Weights)
    }

    func setChartData(xValsArr: [String], yValsArr: [Double]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        for (index, item) in xValsArr.enumerated() {
            let Date = formatter.date(from: item)
            self.yVals1!.append(ChartDataEntry.init(x: Date!.timeIntervalSince1970, y: yValsArr[index] ) )
            print(yVals1!)
        }

        print(xValsArr,yValsArr)

        let set1: LineChartDataSet = LineChartDataSet(entries: yVals1, label: "First Set")
        //set설정
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor.red.withAlphaComponent(0.5)) // our line's opacity is 50%
        set1.drawCirclesEnabled = false
        set1.lineWidth = 0.5
        set1.circleRadius = 6.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.red
        set1.drawFilledEnabled = false
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true

        let LineChartData1 = LineChartData.init(dataSet: set1 as IChartDataSet )
        Chart.xAxis.valueFormatter = axisFormatDelegate
       //data.setValueTextColor(UIColor.whiteColor())
        //self.Chart.xAxis.valueFormatter = self
       //5 - finally set our data
        self.Chart.data = LineChartData1
        //Chart.xAxis.valueFormatter = axisFormatDelegate
        self.Chart.reloadInputViews()
    }
}

//extension BodyChartViewController: IAxisValueFormatter {
//
//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//
//            let date = Date(timeIntervalSince1970: value)
//
//           let formatter = DateFormatter()
//
//           formatter.dateFormat = "yyyy-MM-dd"
//
//           formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
//
//           return formatter.string(from: date)
//
//    }
//
//}
