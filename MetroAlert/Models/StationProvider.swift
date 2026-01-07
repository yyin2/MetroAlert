import Foundation

struct StationProvider {
    static let allStations: [Station] = shanghaiStations
    
    static let beijingStations: [Station] = []
    
    static let shanghaiStations: [Station] = [
        // 1号线
        Station(name: "莘庄", nameEn: "Xinzhuang", line: "1号线", city: "上海"),
        Station(name: "外环路", nameEn: "Waihuan Road", line: "1号线", city: "上海"),
        Station(name: "莲花路", nameEn: "Lianhua Road", line: "1号线", city: "上海"),
        Station(name: "锦江乐园", nameEn: "Jinjiang Park", line: "1号线", city: "上海"),
        Station(name: "上海南站", nameEn: "Shanghai South Railway Station", line: "1号线", city: "上海"),
        Station(name: "漕宝路", nameEn: "Caobao Road", line: "1号线", city: "上海"),
        Station(name: "上海体育馆", nameEn: "Shanghai Indoor Stadium", line: "1号线", city: "上海"),
        Station(name: "徐家汇", nameEn: "Xujiahui", line: "1号线", city: "上海"),
        Station(name: "衡山路", nameEn: "Hengshan Road", line: "1号线", city: "上海"),
        Station(name: "常熟路", nameEn: "Changshu Road", line: "1号线", city: "上海"),
        Station(name: "陕西南路", nameEn: "South Shaanxi Road", line: "1号线", city: "上海"),
        Station(name: "一大会址·黄陂南路", nameEn: "Site of the First CPC National Congress · South Huangpi Road", line: "1号线", city: "上海"),
        Station(name: "人民广场", nameEn: "People's Square", line: "1号线", city: "上海"),
        Station(name: "新闸路", nameEn: "Xinzha Road", line: "1号线", city: "上海"),
        Station(name: "汉中路", nameEn: "Hanzhong Road", line: "1号线", city: "上海"),
        Station(name: "上海火车站", nameEn: "Shanghai Railway Station", line: "1号线", city: "上海"),
        Station(name: "中山北路", nameEn: "North Zhongshan Road", line: "1号线", city: "上海"),
        Station(name: "延长路", nameEn: "Yanchang Road", line: "1号线", city: "上海"),
        Station(name: "上海马戏城", nameEn: "Shanghai Circus World", line: "1号线", city: "上海"),
        Station(name: "汶水路", nameEn: "Wenshui Road", line: "1号线", city: "上海"),
        Station(name: "彭浦新村", nameEn: "Pengpu Xincun", line: "1号线", city: "上海"),
        Station(name: "共康路", nameEn: "Gongkang Road", line: "1号线", city: "上海"),
        Station(name: "通河新村", nameEn: "Tonghe Xincun", line: "1号线", city: "上海"),
        Station(name: "呼兰路", nameEn: "Hulan Road", line: "1号线", city: "上海"),
        Station(name: "共富新村", nameEn: "Gongfu Xincun", line: "1号线", city: "上海"),
        Station(name: "宝安公路", nameEn: "Bao'an Highway", line: "1号线", city: "上海"),
        Station(name: "友谊西路", nameEn: "West Youyi Road", line: "1号线", city: "上海"),
        Station(name: "富锦路", nameEn: "Fujin Road", line: "1号线", city: "上海"),

        // 2号线
        Station(name: "国家会展中心", nameEn: "National Exhibition and Convention Center", line: "2号线", city: "上海"),
        Station(name: "虹桥火车站", nameEn: "Hongqiao Railway Station", line: "2号线", city: "上海"),
        Station(name: "虹桥2号航站楼", nameEn: "Hongqiao Airport Terminal 2", line: "2号线", city: "上海"),
        Station(name: "淞虹路", nameEn: "Songhong Road", line: "2号线", city: "上海"),
        Station(name: "北新泾", nameEn: "Beixinjing", line: "2号线", city: "上海"),
        Station(name: "威宁路", nameEn: "Weining Road", line: "2号线", city: "上海"),
        Station(name: "娄山关路", nameEn: "Loushanguan Road", line: "2号线", city: "上海"),
        Station(name: "中山公园", nameEn: "Zhongshan Park", line: "2号线", city: "上海"),
        Station(name: "江苏路", nameEn: "Jiangsu Road", line: "2号线", city: "上海"),
        Station(name: "静安寺", nameEn: "Jing'an Temple", line: "2号线", city: "上海"),
        Station(name: "南京西路", nameEn: "West Nanjing Road", line: "2号线", city: "上海"),
        Station(name: "人民广场", nameEn: "People's Square", line: "2号线", city: "上海"),
        Station(name: "南京东路", nameEn: "East Nanjing Road", line: "2号线", city: "上海"),
        Station(name: "陆家嘴", nameEn: "Lujiazui", line: "2号线", city: "上海"),
        Station(name: "浦东南路", nameEn: "South Pudong Road", line: "2号线", city: "上海"),
        Station(name: "世纪大道", nameEn: "Century Avenue", line: "2号线", city: "上海"),
        Station(name: "上海科技馆", nameEn: "Shanghai Science and Technology Museum", line: "2号线", city: "上海"),
        Station(name: "世纪公园", nameEn: "Century Park", line: "2号线", city: "上海"),
        Station(name: "龙阳路", nameEn: "Longyang Road", line: "2号线", city: "上海"),
        Station(name: "张江高科", nameEn: "Zhangjiang High Technology Park", line: "2号线", city: "上海"),
        Station(name: "金科路", nameEn: "Jinke Road", line: "2号线", city: "上海"),
        Station(name: "广兰路", nameEn: "Guanglan Road", line: "2号线", city: "上海"),
        Station(name: "唐镇", nameEn: "Tangzhen", line: "2号线", city: "上海"),
        Station(name: "创新中路", nameEn: "Middle Chuangxin Road", line: "2号线", city: "上海"),
        Station(name: "华夏东路", nameEn: "East Huaxia Road", line: "2号线", city: "上海"),
        Station(name: "川沙", nameEn: "Chuansha", line: "2号线", city: "上海"),
        Station(name: "凌空路", nameEn: "Lingkong Road", line: "2号线", city: "上海"),
        Station(name: "远东大道", nameEn: "Yuandong Avenue", line: "2号线", city: "上海"),
        Station(name: "海天三路", nameEn: "Haitian 3rd Road", line: "2号线", city: "上海"),
        Station(name: "浦东国际机场", nameEn: "Pudong International Airport", line: "2号线", city: "上海"),

        // 3号线
        Station(name: "上海南站", nameEn: "Shanghai South Railway Station", line: "3号线", city: "上海"),
        Station(name: "石龙路", nameEn: "Shilong Road", line: "3号线", city: "上海"),
        Station(name: "龙漕路", nameEn: "Longcao Road", line: "3号线", city: "上海"),
        Station(name: "漕溪路", nameEn: "Caoxi Road", line: "3号线", city: "上海"),
        Station(name: "宜山路", nameEn: "Yishan Road", line: "3号线", city: "上海"),
        Station(name: "虹桥路", nameEn: "Hongqiao Road", line: "3号线", city: "上海"),
        Station(name: "延安西路", nameEn: "West Yan'an Road", line: "3号线", city: "上海"),
        Station(name: "中山公园", nameEn: "Zhongshan Park", line: "3号线", city: "上海"),
        Station(name: "曹杨路", nameEn: "Caoyang Road", line: "3号线", city: "上海"),
        Station(name: "中潭路", nameEn: "Zhongtan Road", line: "3号线", city: "上海"),
        Station(name: "上海火车站", nameEn: "Shanghai Railway Station", line: "3号线", city: "上海"),
        Station(name: "虹口足球场", nameEn: "Hongkou Football Stadium", line: "3号线", city: "上海"),
        Station(name: "江杨北路", nameEn: "North Jiangyang Road", line: "3号线", city: "上海"),

        // 4号线
        Station(name: "延安西路", nameEn: "West Yan'an Road", line: "4号线", city: "上海"),
        Station(name: "虹桥路", nameEn: "Hongqiao Road", line: "4号线", city: "上海"),
        Station(name: "宜山路", nameEn: "Yishan Road", line: "4号线", city: "上海"),
        Station(name: "上海体育馆", nameEn: "Shanghai Indoor Stadium", line: "4号线", city: "上海"),
        Station(name: "上海体育场", nameEn: "Shanghai Stadium", line: "4号线", city: "上海"),
        Station(name: "西藏南路", nameEn: "South Xizang Road", line: "4号线", city: "上海"),
        Station(name: "世纪大道", nameEn: "Century Avenue", line: "4号线", city: "上海"),

        // 5号线
        Station(name: "春申路", nameEn: "Chunshen Road", line: "5号线", city: "上海"),
        Station(name: "银都路", nameEn: "Yindu Road", line: "5号线", city: "上海"),
        Station(name: "颛桥", nameEn: "Zhuanqiao", line: "5号线", city: "上海"),
        Station(name: "北桥", nameEn: "Beiqiao", line: "5号线", city: "上海"),
        Station(name: "奉贤新城", nameEn: "Fengxian Xincheng", line: "5号线", city: "上海"),

        // 7号线
        Station(name: "美兰湖", nameEn: "Meilan Lake", line: "7号线", city: "上海"),
        Station(name: "罗南新村", nameEn: "Luonan Xincun", line: "7号线", city: "上海"),
        Station(name: "顾村公园", nameEn: "Gucun Park", line: "7号线", city: "上海"),
        Station(name: "大场镇", nameEn: "Dachang Town", line: "7号线", city: "上海"),
        Station(name: "镇坪路", nameEn: "Zhenping Road", line: "7号线", city: "上海"),
        Station(name: "静安寺", nameEn: "Jing'an Temple", line: "7号线", city: "上海"),
        Station(name: "肇嘉浜路", nameEn: "Zhaojiabang Road", line: "7号线", city: "上海"),
        Station(name: "花木路", nameEn: "Huamu Road", line: "7号线", city: "上海"),

        // 8号线
        Station(name: "市光路", nameEn: "Shiguang Road", line: "8号线", city: "上海"),
        Station(name: "虹口足球场", nameEn: "Hongkou Football Stadium", line: "8号线", city: "上海"),
        Station(name: "曲阜路", nameEn: "Qufu Road", line: "8号线", city: "上海"),
        Station(name: "人民广场", nameEn: "People's Square", line: "8号线", city: "上海"),
        Station(name: "大世界", nameEn: "Dashijie", line: "8号线", city: "上海"),
        Station(name: "老西门", nameEn: "Laoximen", line: "8号线", city: "上海"),
        Station(name: "中华艺术宫", nameEn: "China Art Museum", line: "8号线", city: "上海"),
        Station(name: "东方体育中心", nameEn: "Oriental Sports Center", line: "8号线", city: "上海"),

        // 9号线
        Station(name: "松江大学城", nameEn: "Songjiang University Town", line: "9号线", city: "上海"),
        Station(name: "佘山", nameEn: "Sheshan", line: "9号线", city: "上海"),
        Station(name: "七宝", nameEn: "Qibao", line: "9号线", city: "上海"),
        Station(name: "漕河泾开发区", nameEn: "Caohejing Hi-Tech Park", line: "9号线", city: "上海"),
        Station(name: "徐家汇", nameEn: "Xujiahui", line: "9号线", city: "上海"),
        Station(name: "世纪大道", nameEn: "Century Avenue", line: "9号线", city: "上海"),
        Station(name: "曹路", nameEn: "Caolu", line: "9号线", city: "上海"),

        // 10号线
        Station(name: "虹桥火车站", nameEn: "Hongqiao Railway Station", line: "10号线", city: "上海"),
        Station(name: "上海动物园", nameEn: "Shanghai Zoo", line: "10号线", city: "上海"),
        Station(name: "交通大学", nameEn: "Jiaotong University", line: "10号线", city: "上海"),
        Station(name: "一大会址·新天地", nameEn: "Site of the First CPC National Congress · Xintiandi", line: "10号线", city: "上海"),
        Station(name: "豫园", nameEn: "Yu Garden", line: "10号线", city: "上海"),
        Station(name: "南京东路", nameEn: "East Nanjing Road", line: "10号线", city: "上海"),
        Station(name: "五角场", nameEn: "Wujiaochang", line: "10号线", city: "上海"),
        Station(name: "基隆路", nameEn: "Jilong Road", line: "10号线", city: "上海"),

        // 11号线
        Station(name: "嘉定北", nameEn: "Jiading North", line: "11号线", city: "上海"),
        Station(name: "安亭", nameEn: "Anting", line: "11号线", city: "上海"),
        Station(name: "花桥", nameEn: "Huaqiao", line: "11号线", city: "上海"),
        Station(name: "南翔", nameEn: "Nanxiang", line: "11号线", city: "上海"),
        Station(name: "江苏路", nameEn: "Jiangsu Road", line: "11号线", city: "上海"),
        Station(name: "迪士尼", nameEn: "Disney Resort", line: "11号线", city: "上海"),

        // 12号线
        Station(name: "七莘路", nameEn: "Qixin Road", line: "12号线", city: "上海"),
        Station(name: "龙漕路", nameEn: "Longcao Road", line: "12号线", city: "上海"),
        Station(name: "汉中路", nameEn: "Hanzhong Road", line: "12号线", city: "上海"),
        Station(name: "南京西路", nameEn: "West Nanjing Road", line: "12号线", city: "上海"),

        // 13号线
        Station(name: "金运路", nameEn: "Jinyun Road", line: "13号线", city: "上海"),
        Station(name: "淮海中路", nameEn: "Middle Huaihai Road", line: "13号线", city: "上海"),
        Station(name: "学林路", nameEn: "Xuelin Road", line: "13号线", city: "上海"),

        // 14号线
        Station(name: "封浜", nameEn: "Fengbang", line: "14号线", city: "上海"),
        Station(name: "真如", nameEn: "Zhenru", line: "14号线", city: "上海"),
        Station(name: "武宁路", nameEn: "Wuning Road", line: "14号线", city: "上海"),
        Station(name: "静安寺", nameEn: "Jing'an Temple", line: "14号线", city: "上海"),
        Station(name: "陆家嘴", nameEn: "Lujiazui", line: "14号线", city: "上海"),

        // 15号线
        Station(name: "紫竹高新区", nameEn: "Zizhu Hi-tech Zone", line: "15号线", city: "上海"),
        Station(name: "华东理工大学", nameEn: "East China University of Science and Technology", line: "15号线", city: "上海"),

        // 16号线
        Station(name: "龙阳路", nameEn: "Longyang Road", line: "16号线", city: "上海"),
        Station(name: "惠南", nameEn: "Huinan", line: "16号线", city: "上海"),
        Station(name: "滴水湖", nameEn: "Dishui Lake", line: "16号线", city: "上海"),

        // 17号线
        Station(name: "东方绿舟", nameEn: "Oriental Land", line: "17号线", city: "上海"),
        Station(name: "西岑", nameEn: "Xicen", line: "17号线", city: "上海"),

        // 18号线
        Station(name: "复旦大学", nameEn: "Fudan University", line: "18号线", city: "上海"),
        Station(name: "航头", nameEn: "Hangtou", line: "18号线", city: "上海"),

        // 磁浮线
        Station(name: "浦东国际机场", nameEn: "Pudong International Airport", line: "磁浮线", city: "上海")
    ]
}
