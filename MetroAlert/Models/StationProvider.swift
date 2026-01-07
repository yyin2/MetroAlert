import Foundation

struct StationProvider {
    static let allStations: [Station] = beijingStations + shanghaiStations
    
    static let beijingStations: [Station] = [
        // 北京 1号线
        Station(name: "四惠", nameEn: "Sihui", line: "1号线", city: "北京"),
        Station(name: "大望路", nameEn: "Dawanglu", line: "1号线", city: "北京"),
        Station(name: "国贸", nameEn: "Guomao", line: "1号线", city: "北京"),
        Station(name: "王府井", nameEn: "Wangfujing", line: "1号线", city: "北京"),
        Station(name: "天安门东", nameEn: "Tian'anmen Dong", line: "1号线", city: "北京"),
        Station(name: "西单", nameEn: "Xidan", line: "1号线", city: "北京"),
        Station(name: "复兴门", nameEn: "Fuxingmen", line: "1号线", city: "北京"),
        Station(name: "公主坟", nameEn: "Gongzhufen", line: "1号线", city: "北京"),
        Station(name: "五棵松", nameEn: "Wukesong", line: "1号线", city: "北京"),
        // 北京 2号线
        Station(name: "北京站", nameEn: "Beijing Railway Station", line: "2号线", city: "北京"),
        Station(name: "前门", nameEn: "Qianmen", line: "2号线", city: "北京"),
        Station(name: "宣武门", nameEn: "Xuanwumen", line: "2号线", city: "北京"),
        Station(name: "西直门", nameEn: "Xizhimen", line: "2号线", city: "北京"),
        Station(name: "鼓楼大街", nameEn: "Gulou Dajie", line: "2号线", city: "北京"),
        Station(name: "雍和宫", nameEn: "Yonghegong Lama Temple", line: "2号线", city: "北京"),
        // 北京 10号线
        Station(name: "三元桥", nameEn: "Sanyuanqiao", line: "10号线", city: "北京"),
        Station(name: "亮马桥", nameEn: "Liangmaqiao", line: "10号线", city: "北京"),
        Station(name: "团结湖", nameEn: "Tuanjiehu", line: "10号线", city: "北京"),
        Station(name: "呼家楼", nameEn: "Hujialou", line: "10号线", city: "北京"),
        Station(name: "双井", nameEn: "Shuangjing", line: "10号线", city: "北京"),
        // 北京 4号线
        Station(name: "北京南站", nameEn: "Beijing South Railway Station", line: "4号线", city: "北京"),
        Station(name: "中关村", nameEn: "Zhongguancun", line: "4号线", city: "北京"),
        Station(name: "圆明园", nameEn: "Old Summer Palace", line: "4号线", city: "北京")
    ]
    
    static let shanghaiStations: [Station] = [
        // 上海 1号线
        Station(name: "莘庄", nameEn: "Xinzhuang", line: "1号线", city: "上海"),
        Station(name: "徐家汇", nameEn: "Xujiahui", line: "1号线", city: "上海"),
        Station(name: "常熟路", nameEn: "Changshu Road", line: "1号线", city: "上海"),
        Station(name: "陕西南路", nameEn: "South Shaanxi Road", line: "1号线", city: "上海"),
        Station(name: "人民广场", nameEn: "People's Square", line: "1号线", city: "上海"),
        Station(name: "上海火车站", nameEn: "Shanghai Railway Station", line: "1号线", city: "上海"),
        // 上海 2号线
        Station(name: "静安寺", nameEn: "Jing'an Temple", line: "2号线", city: "上海"),
        Station(name: "南京西路", nameEn: "West Nanjing Road", line: "2号线", city: "上海"),
        Station(name: "南京东路", nameEn: "East Nanjing Road", line: "2号线", city: "上海"),
        Station(name: "陆家嘴", nameEn: "Lujiazui", line: "2号线", city: "上海"),
        Station(name: "世纪大道", nameEn: "Century Avenue", line: "2号线", city: "上海"),
        Station(name: "龙阳路", nameEn: "Longyang Road", line: "2号线", city: "上海"),
        Station(name: "浦东国际机场", nameEn: "Pudong International Airport", line: "2号线", city: "上海"),
        Station(name: "虹桥火车站", nameEn: "Hongqiao Railway Station", line: "2号线", city: "上海"),
        // 上海 10号线
        Station(name: "新天地", nameEn: "Xintiandi", line: "10号线", city: "上海"),
        Station(name: "豫园", nameEn: "Yu Garden", line: "10号线", city: "上海"),
        Station(name: "交通大学", nameEn: "Jiaotong University", line: "10号线", city: "上海")
    ]
}
