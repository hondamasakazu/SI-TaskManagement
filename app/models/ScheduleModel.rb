# -*- encoding: utf-8 -*-
#require "gcalapi";
require 'time';

class ScheduleModel
  # コンストラクタ。
  def initialize(googleCalObj)
    # GoogleCalendarを受け取り、クラス変数に保持する。
    @googleCalObj = googleCalObj;
  end
  attr_accessor :googleCalObj
  attr_accessor :username
  
  
  # メソッド定義。
  def getTitle()
    return googleCalObj.summary
  end
  def getDesc()
    return googleCalObj.description
  end
  def getDesc_FirstLine()
    str = googleCalObj.description
    if str==nil
      return nil
    end
    # 先頭行のみを返す。
    return str[/[^\r\n]*/]
  end
  def checkSectionList?()
    sectionList = getSectionList()
    sectionList.each do |section|
      if (section == nil || section == "")
        return false
      end
    end
    return true
  end
  def getSectionList()
    line = getDesc_FirstLine()
    if line == nil
      return ["", "", ""]
    end
    /([^,]*),([^,]*),([^,]*)/ =~ getDesc_FirstLine()
    sectionList = [ $1, $2, $3 ]
    return sectionList
  end
  def getWhere()
    #return googleCalObj.where
  end
  def getWorkTimeHours(unit=1)
    min = getWorkTimeMinuts(unit)
    hour = min / 60.0
    return hour
  end
  def getWorkTimeMinuts(unit=1)
    startTime = googleCalObj.start.dateTime
    endTime = googleCalObj.end.dateTime
    
    days = (endTime - startTime).divmod(24*60*60) #=> [2.0, 45000.0]
    hours = days[1].divmod(60*60) #=> [12.0, 1800.0]
    mins = hours[1].divmod(60) #=> [30.0, 0.0]  
    
    min = days[0].to_i * 24*60 + hours[0].to_i * 60 + mins[0].to_i
    
    mod = min % unit
    
    return min - mod 
  end
  def getStartDate()
    return googleCalObj.start.dateTime
  end
  def getEndDate()
    return googleCalObj.end.dateTime
  end
  
  def isProcessTarget?()
    sectionList = getSectionList()
    if (sectionList[0] == "" || sectionList[1] == "" || sectionList[2] == "")
      return false
    end
    if (sectionList[0] == nil || sectionList[1] == nil || sectionList[2] == nil)
      return false
    end
    
    # 3セクションとも設定している。
    return true
  end
  
  def getTermString()
    # 開始と終了の日時を取得。
    startDate = @googleCalObj.start.dateTime
    endDate = @googleCalObj.end.dateTime
    # 開始日付, 開始時刻, 終了時刻を文字列として取得。
    start_date_string = startDate.strftime("%Y/%m/%d")
    start_time_string = startDate.strftime("%H:%M")
    end_time_string = endDate.strftime("%H:%M")
    # 期間の文字列を作成。
    ret_value = sprintf("%s  %s - %s", start_date_string, start_time_string, end_time_string)
    return ret_value
  end
  
  def getSameSectionIndexBeforeMyself(scheduleList)
    index = 0
    mySectionList = getSectionList()
    if (checkSectionList? == false)
      return -1
    end
    scheduleList.getList.each do |schedule|
      if (schedule.isProcessTarget? == false)
        next
      end
      tmpSectionList = schedule.getSectionList()
      if (mySectionList[0] == "A001")
        # i = 1
      end
      if (mySectionList[0] != tmpSectionList[0])
      index +=1
        next
      end
      if (mySectionList[1] != tmpSectionList[1])
      index +=1
        next
      end
      if (mySectionList[2] != tmpSectionList[2])
      index +=1
        next
      end
      
      # 分類の内容が一致した。
      if (self == schedule)
        return -1
      end
      if (self != schedule)
        # ただしオブジェクトは一致せず。
        return index
      end
      index +=1
    end
    
    return -1
  end
  def isSameSection?(schedule)
    if (checkSectionList? == false)
      # 自分のセクション情報自体が不正。
      return false
    end
    if (schedule.isProcessTarget? == false)
      return false
    end
    
    # 自分のセクション情報を取得。
    mySectionList = getSectionList()
    # 引数のセクション情報を取得。
    tmpSectionList = schedule.getSectionList()
    if (mySectionList[0] != tmpSectionList[0])
      return false # 内容一致せず。
    end
    if (mySectionList[1] != tmpSectionList[1])
      return false # 内容一致せず。
    end
    if (mySectionList[2] != tmpSectionList[2])
      return false # 内容一致せず。
    end
      
    # 分類の内容が一致した。
    return true
  end
end
