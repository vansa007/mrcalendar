//
//  MrCalenderView.swift
//  MrCalendar
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 VANSA. All rights reserved.
//

import UIKit

class MrCalenderView: UIView {
    
    lazy var calendarScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.delegate = self
        return sv
    }()
    
    lazy var scrollContentView: UIView = {
        let viw = UIView()
        viw.translatesAutoresizingMaskIntoConstraints = false
        viw.backgroundColor = .green
        return viw
    }()
    
    lazy var previousMonthBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(#imageLiteral(resourceName: "backward_icon"), for: .normal)
        btn.addTarget(self, action: #selector(previousMonthAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var currentSetDateLb: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.boldSystemFont(ofSize: 18.0)
        lb.text = "Jan 2018"
        lb.textColor = UIColor.black
        lb.textAlignment = .center
        return lb
    }()
    
    lazy var nextMonthBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(#imageLiteral(resourceName: "forward_icon"), for: .normal)
        btn.addTarget(self, action: #selector(nextMonthAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var currentSelectDateStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .equalSpacing
        
        sv.addArrangedSubview(previousMonthBtn)
        sv.addArrangedSubview(currentSetDateLb)
        sv.addArrangedSubview(nextMonthBtn)
        
        previousMonthBtn.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        currentSetDateLb.widthAnchor.constraint(equalToConstant: 140.0).isActive = true
        nextMonthBtn.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        return sv
    }()
    
    lazy var dateNameStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fillEqually
        for dayName in dayNameArr {
            let dayNameLb = UILabel()
            dayNameLb.font = UIFont.boldSystemFont(ofSize: 16.0)
            dayNameLb.textColor = UIColor.black
            dayNameLb.text = dayName
            dayNameLb.textAlignment = .center
            sv.addArrangedSubview(dayNameLb)
        }
        return sv
    }()
    
    lazy var itemDateCollectionView: UICollectionView = {
        layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let heightOfColViw: CGFloat = frame.height - (currentSelectDateStackView.frame.height + dateNameStackView.frame.height + 24.0)
        layout.itemSize = CGSize(width: frame.width/CGFloat(dayNameArr.count), height: heightOfColViw/6)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        let collView = UICollectionView(frame: CGRect(x: 0, y: 0, width: scrollContentView.frame.width, height: scrollContentView.frame.height), collectionViewLayout: layout)
        //collView.translatesAutoresizingMaskIntoConstraints = true
//        collView.delegate = self
//        collView.dataSource = self
        collView.register(DateItem.self, forCellWithReuseIdentifier: cellId)
        collView.showsVerticalScrollIndicator = false
        collView.showsHorizontalScrollIndicator = false
        collView.backgroundColor = .white
        collView.clipsToBounds = false
        return collView
    }()
    
    let dayNameArr: [String] = { return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] }()
    let cellId: String = "date_item_cell_id"
    var isJustLoadingView: Bool = true
    var dateSelected: Date? {
        didSet {
            let currentCollectionView = collectionViewArr[currentMonthValue-1]
            currentCollectionView.reloadData()
        }
    }
    
    var currentDayValue: Int = 0
    var currentMonthValue: Int = 0 {
        didSet {
            if !isJustLoadingView {
                renderComponent()
                //let currentCollectionView = collectionViewArr[currentMonthValue-1]
                //currentCollectionView.reloadData()
            }
        }
    }
    var currentYearValue: Int = 0
    var collectionViewArr = Array<UICollectionView>()
    var startingMonthValue: Int = 0
    
    private func setDefaultValue() {
        let currentDate = getCurrentDate()
        currentDayValue = getCurrentDay(date: currentDate)
        currentMonthValue = getCurrentMonth(date: currentDate)
        startingMonthValue = currentMonthValue
        currentYearValue = getCurrentYear(date: currentDate)
        isJustLoadingView = false
    }
    
    override public init(frame: CGRect) {
        super.init(frame:frame)
        setDefaultValue()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setDefaultValue()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupDateControllerStackView()
        setupDayNameStackView()
        renderComponent()
        setupCollectionItemDate()
    }
    
    private func renderComponent() {
        guard let date = convertToDate(year: self.currentYearValue, month: self.currentMonthValue, day: self.currentDayValue) else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        let currentDateSt = dateFormatter.string(from: date)
        currentSetDateLb.text = currentDateSt
    }
    
    private func setupDateControllerStackView() {
        addSubview(currentSelectDateStackView)
        currentSelectDateStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0).isActive = true
        currentSelectDateStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        currentSelectDateStackView.heightAnchor.constraint(equalToConstant: 27.0).isActive = true
        layoutIfNeeded()
    }
    
    private func setupDayNameStackView() {
        addSubview(dateNameStackView)
        dateNameStackView.topAnchor.constraint(equalTo: currentSelectDateStackView.bottomAnchor, constant: 8.0).isActive = true
        dateNameStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dateNameStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dateNameStackView.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
    }
    
    private func setupCollectionItemDate() {
        
        addSubview(calendarScrollView)
        calendarScrollView.topAnchor.constraint(equalTo: dateNameStackView.bottomAnchor, constant: 8.0).isActive = true
        calendarScrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        calendarScrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        calendarScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        layoutIfNeeded()
        
        calendarScrollView.contentSize = CGSize(width: calendarScrollView.frame.width * CGFloat(2), height: calendarScrollView.frame.height)
        
        for idx in 0..<1 {
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let heightOfColViw: CGFloat = frame.height - (currentSelectDateStackView.frame.height + dateNameStackView.frame.height + 24.0)
            layout.itemSize = CGSize(width: frame.width/CGFloat(dayNameArr.count), height: heightOfColViw/6)
            layout.minimumLineSpacing = 0.0
            layout.minimumInteritemSpacing = 0.0
            
            let xPoint: CGFloat = calendarScrollView.frame.width * CGFloat(idx)
            let collFrame = CGRect(x: xPoint, y: 0, width: calendarScrollView.frame.width, height: calendarScrollView.frame.height)
            let collView = UICollectionView(frame: collFrame, collectionViewLayout: layout)
            collView.register(DateItem.self, forCellWithReuseIdentifier: cellId)
            collView.showsVerticalScrollIndicator = false
            collView.showsHorizontalScrollIndicator = false
            collView.backgroundColor = .white
            collView.clipsToBounds = false
            collectionViewArr.append(collView)
            collView.delegate = self
            collView.dataSource = self
            calendarScrollView.addSubview(collView)
        }
    }
    
    private func addCollection(_ scrollView: UIScrollView) {
        let pageWidth  : CGFloat = scrollView.bounds.size.width
        let indexRow = Int(floor((scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1.0)
        
        if indexRow == (collectionViewArr.count - 1) {
            calendarScrollView.contentSize = CGSize(width: calendarScrollView.frame.width * CGFloat(collectionViewArr.count + 1), height: calendarScrollView.frame.height)
            createNewCollection(idx: indexRow + 1)
        }
    }
    
    private func createNewCollection(idx: Int) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let heightOfColViw: CGFloat = frame.height - (currentSelectDateStackView.frame.height + dateNameStackView.frame.height + 24.0)
        layout.itemSize = CGSize(width: frame.width/CGFloat(dayNameArr.count), height: heightOfColViw/6)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        let xPoint: CGFloat = calendarScrollView.frame.width * CGFloat(idx)
        let collFrame = CGRect(x: xPoint, y: 0, width: calendarScrollView.frame.width, height: calendarScrollView.frame.height)
        let collView = UICollectionView(frame: collFrame, collectionViewLayout: layout)
        collView.register(DateItem.self, forCellWithReuseIdentifier: cellId)
        collView.showsVerticalScrollIndicator = false
        collView.showsHorizontalScrollIndicator = false
        collView.backgroundColor = .white
        collView.clipsToBounds = false
        collectionViewArr.append(collView)
        collView.delegate = self
        collView.dataSource = self
        calendarScrollView.addSubview(collView)
    }
    
    
    private func getDayStartDay(monthNum: Int) -> Int? {
        var outputIndex: Int?
        let month = monthNum
        let monthSt = month < 10 ? "0\(month)" : "\(month)"
        let year = self.currentYearValue
        let yearSt = "\(year)"
        let firstDayOfMonthDateSt = "01-\(monthSt)-\(yearSt)"
        let firstDayOfMonthFormatter = DateFormatter()
        firstDayOfMonthFormatter.dateFormat = "dd-MM-yyyy"
        if let firstDayDate = firstDayOfMonthFormatter.date(from: firstDayOfMonthDateSt) {
            let dateDateFormatter = DateFormatter()
            dateDateFormatter.dateFormat = "EEE"
            let dayInWeek = dateDateFormatter.string(from: firstDayDate)
            outputIndex = dayNameArr.firstIndex(of: dayInWeek)
        }
        return outputIndex
    }
    
    private func lastDay(ofMonth m: Int, year y: Int) -> Int {
        let cal = Calendar.current
        var comps = DateComponents(calendar: cal, year: y, month: m)
        comps.setValue(m + 1, for: .month)
        comps.setValue(0, for: .day)
        let date = cal.date(from: comps)!
        return cal.component(.day, from: date)
    }
    
    private func getLastDayOfCurrentDate() -> Int {
        return lastDay(ofMonth: self.currentMonthValue, year: self.currentYearValue)
    }
    
    private func isPreviousDay(day: Int) -> Bool {
        let calendar = Calendar.current
        let date = Date()
        let today = calendar.component(.day, from: date)
        return day < today
    }
    
    private func compareManuallyDateWithCurrentDate(day: Int) -> Bool {
        let currentDate = getCurrentDate()
        guard let manuallyDate = convertToDate(year: self.currentYearValue, month: self.currentMonthValue, day: day) else { return false }
        switch currentDate.compare(manuallyDate) {
        case .orderedAscending: return true //good => end date bigger than start date
        case .orderedDescending: return false //bad => end date smaller than start date
        case .orderedSame: return true //acceptable => start date = end date
        }
    }
    
    private func compareEqual2Dates(date1: Date, date2: Date) -> Bool {
        switch date1.compare(date2) {
        case .orderedAscending: return false
        case .orderedDescending: return false
        case .orderedSame: return true
        }
    }
    
    private func convertToDate(year: Int, month: Int, day: Int) -> Date? {
        let yearSt = "\(year)"
        let monthSt = month < 10 ? "0\(month)" : "\(month)"
        let daySt = day < 10 ? "0\(day)" : "\(day)"
        let fullDateSt = yearSt + "-" + monthSt + "-" + daySt
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFromSt = dateFormatter.date(from: fullDateSt)
        return dateFromSt
    }
    
    private func getCurrentDate() -> Date {
        let calendar = Calendar.current
        let date = Date()
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return convertToDate(year: year, month: month, day: day)!
    }
    
    private func getCurrentDay(date: Date) -> Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        return day
    }
    
    private func getCurrentMonth(date: Date) -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        return month
    }
    
    private func getCurrentYear(date: Date) -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return year
    }
    
    @objc func previousMonthAction(_ sender: UIButton) {
        if currentMonthValue == 1 {
            currentYearValue -= 1
            currentMonthValue = 12
        } else {
            currentMonthValue -= 1
        }
    }
    
    @objc func nextMonthAction(_ sender: UIButton) {
        if currentMonthValue == 12 {
            currentYearValue += 1
            currentMonthValue = 1
        } else {
            currentMonthValue += 1
        }
    }
}

extension MrCalenderView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let idxStart = getDayStartDay(monthNum: self.currentMonthValue) else { return }
        let renderValue: Int = indexPath.row - idxStart + 1
        if compareManuallyDateWithCurrentDate(day: renderValue) && (renderValue <= getLastDayOfCurrentDate()) {
            dateSelected = convertToDate(year: self.currentYearValue, month: self.currentMonthValue, day: renderValue)
        }
    }
    
}

extension MrCalenderView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 * 6 //number day in a week * 6 lines
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? DateItem else { return UICollectionViewCell() }
        guard let idxStart = getDayStartDay(monthNum: self.currentMonthValue) else { return UICollectionViewCell() }
        let renderValue = indexPath.row - idxStart + 1
        if (indexPath.row >= idxStart) && (renderValue <= getLastDayOfCurrentDate()) {
            cell.itemLb.textColor = compareManuallyDateWithCurrentDate(day: renderValue) ? UIColor.black : UIColor.gray
            cell.itemLb.text = "\(renderValue)"
        }
        //keep highlight on date selected
        if let _dateSelected = dateSelected, let dateOnCalendar = convertToDate(year: self.currentYearValue, month: self.currentMonthValue, day: renderValue) {
            let compareationDate = compareEqual2Dates(date1: _dateSelected, date2: dateOnCalendar)
            cell.setSelectStyle(isSelect: compareationDate)
        }
        return cell
    }
    
}

extension MrCalenderView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth  : CGFloat = scrollView.bounds.size.width
        let indexRow = Int(floor((scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1.0)
        currentMonthValue = startingMonthValue + indexRow
        var currentCollectionView = UICollectionView()
//        addCollection(scrollView)
        if indexRow == (collectionViewArr.count - 1) {
            calendarScrollView.contentSize = CGSize(width: calendarScrollView.frame.width * CGFloat(collectionViewArr.count + 1), height: calendarScrollView.frame.height)
            createNewCollection(idx: indexRow + 1)
            currentCollectionView = collectionViewArr[collectionViewArr.count - 1]
        } else {
            currentCollectionView = collectionViewArr[indexRow]
        }
        DispatchQueue.main.async {
            currentCollectionView.reloadData()
        }
    }
    
}

class DateItem: UICollectionViewCell {
    
    lazy var itemLb: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.systemFont(ofSize: 16.0)
        lb.textAlignment = .center
        lb.textColor = .black
        lb.backgroundColor = UIColor.clear
        lb.clipsToBounds = true
        return lb
    }()
    
    private func setupItemLabel() {
        addSubview(itemLb)
        let widthHeight: CGFloat = 40.0
        itemLb.widthAnchor.constraint(equalToConstant: widthHeight).isActive = true
        itemLb.heightAnchor.constraint(equalToConstant: widthHeight).isActive = true
        itemLb.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        itemLb.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        itemLb.layer.cornerRadius = widthHeight/2
    }
    
    public func setSelectStyle(isSelect: Bool) {
        if isSelect {
            itemLb.textColor = UIColor.white
            itemLb.backgroundColor = UIColor(red: 240/255, green: 40/255, blue: 135/255, alpha: 1.0)
        } else {
            itemLb.backgroundColor = UIColor.clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupItemLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemLb.text = nil
        itemLb.textColor = UIColor.clear
        itemLb.backgroundColor = UIColor.clear
    }
    
    public func cellRendering(row: Int) {
        itemLb.textColor = isPreviousDay(day: row) ? UIColor.gray : UIColor.black
        itemLb.text = "\(row)"
    }
    
    private func isPreviousDay(day: Int) -> Bool {
        let calendar = Calendar.current
        let date = Date()
        let today = calendar.component(.day, from: date)
        return day < today
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
