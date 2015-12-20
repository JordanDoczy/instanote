//
//  SampleData.swift
//  RememberThat
//
//  Created by Jordan Doczy on 12/7/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import MapKit
import Photos

class SampleData {
    
    static let locations = [[39.5094604492188, -76.1630096435547], [32.4541053771973, -99.7346801757813], [39.4286956787109, -74.5075378417969], [34.5582656860352, -117.40421295166], [41.0805740356445, -81.5156631469727], [44.6307563781738, -123.099647521973], [42.6416473388672, -73.7412567138672], [42.2473754882813, -84.7563247680664], [35.082935333252, -106.646980285645], [40.8171195983887, -91.1035919189453], [37.7242393493652, -80.644645690918], [38.8062438964844, -77.0626449584961], [27.7454128265381, -98.0823516845703], [40.5904312133789, -75.5671920776367], [40.6523323059082, -75.4403915405273], [40.9217872619629, -81.0958099365234], [30.3571586608887, -103.661041259766], [38.9044914245605, -90.1349487304688], [40.5147819519043, -78.400993347168], [42.3748588562012, -72.5119247436523], [42.953676, -74.219553], [33.8042602539063, -117.884819030762], [42.2880516052246, -83.744026184082], [33.648998260498, -85.8318862915039], [38.0180854797363, -121.815132141113], [44.265941619873, -88.405647277832], [40.8675727844238, -124.083938598633], [34.1719131469727, -97.1254119873047], [40.0072631835938, -75.2894439697266], [34.1143760681152, -93.0524444580078], [38.4809303283691, -82.6394729614258], [42.188117980957, -122.697021484375], [37.7592353820801, -77.4816741943359], [35.4892082214355, -120.665710449219], [33.7995643615723, -84.3917846679688], [39.3630027770996, -74.4398651123047], [31.0243282318115, -87.4873352050781], [38.904182434082, -121.08203125], [30.2690925598145, -97.7555694580078], [42.3473052978516, -71.0763549804688], [44.782054901123, -117.811325073242], [35.3713798522949, -119.0224609375], [39.3081207275391, -76.6174774169922], [42.3141860961914, -86.1118698120117], [34.9048004150391, -117.025352478027], [36.7506332397461, -95.9353637695313], [34.3160209655762, -89.9523849487305], [30.4496574401855, -91.1765975952148], [42.3169746398926, -85.1856918334961], [30.8809204101563, -87.7730331420898], [30.3069000244141, -89.3373336791992], [33.9280471801758, -116.976509094238], [30.0769062042236, -94.1229629516602], [34.6642417907715, -106.774871826172], [38.5209197998047, -89.9914627075195], [48.7204856872559, -122.509887695313], [43.1358261108398, -72.4454498291016], [42.4988403320313, -89.0354919433594], [44.0553398132324, -121.273406982422], [31.968168258667, -110.293983459473], [37.867603302002, -122.299995422363], [41.6355247497559, -72.7657241821289], [40.6523895263672, -75.4132537841797], [40.6113548278809, -75.3778686523438], [43.6983184814453, -85.482048034668], [32.252571105957, -101.473014831543], [30.3991203308105, -88.8911437988281], [45.7153854370117, -121.469093322754], [33.512393951416, -86.8070297241211], [42.5457229614258, -83.1952972412109], [40.5083465576172, -88.9840393066406], [43.6194686889648, -116.206108093262], [34.9997825622559, -117.656806945801], [32.5255584716797, -93.6801528930664], [42.3515243530273, -71.0552978515625], [40.0583953857422, -105.281181335449], [45.2048416137695, -85.0266494750977], [45.168399810791, -84.9162139892578], [27.4903964996338, -82.4706726074219], [43.6910552978516, -79.762321472168], [43.7991752624512, -73.0892333984375], [36.6443901062012, -93.2272033691406], [43.1457290649414, -80.2623596191406], [42.838695526123, -72.5503540039063], [31.1048641204834, -87.0700454711914], [41.1767463684082, -73.1874008178711], [31.5787582397461, -90.4421234130859], [48.5332946777344, -113.010841369629], [25.8998851776123, -97.4994506835938], [41.4803466796875, -84.5527496337891], [44.5043983459473, -85.6766357421875], [34.6113395690918, -120.193382263184], [42.9069175720215, -78.7266082763672], [42.8784828186035, -78.8750610351563], [34.1938323974609, -118.355911254883], [44.4760551452637, -73.2147979736328], [40.8059425354004, -91.1019821166992], [36.0941772460938, -79.4362869262695], [44.4925727844238, -73.1104507446289], [43.5904006958008, -119.05339050293], [41.7452964782715, -70.6175308227539], [39.1895523071289, -76.6933975219727], [44.2683944702148, -85.4066925048828], [37.6121940612793, -114.515647888184], [38.5798683166504, -122.577812194824], [34.2164688110352, -119.033111572266], [34.2473487854004, -80.6261596679688], [38.6606636047363, -120.968162536621], [34.6257781982422, -111.880638122559], [32.6148109436035, -90.0405197143555], [37.7240867614746, -89.2163696289063], [39.2793273925781, -89.888916015625], [36.5393180847168, -121.908042907715], [34.3960037231445, -119.52131652832], [39.1666488647461, -119.765777587891], [35.7877082824707, -78.7796783447266], [38.4380989074707, -82.6084442138672], [38.5277709960938, -89.1361923217773], [46.7174224853516, -122.951881408691], [40.1161956787109, -88.2409286499023], [32.8755340576172, -79.9989013671875], [38.3519897460938, -81.6467208862305], [35.2411460876465, -80.8236389160156], [38.0320320129395, -78.4921112060547], [42.4023704528809, -82.1850433349609], [34.2571182250977, -118.598731994629], [35.030704498291, -85.1943893432617], [43.2169036865234, -121.780662536621], [39.9274826049805, -75.0424346923828], [41.12158203125, -104.805183410645], [41.0911102294922, -104.98690032959], [41.8787307739258, -87.6391677856445], [39.7233085632324, -121.844718933105], [40.9299545288086, -89.4942169189453], [30.7807273864746, -85.5376129150391], [39.1023788452148, -84.5365295410156], [34.0945281982422, -117.715507507324], [43.3687858581543, -72.3793029785156], [27.9755153656006, -82.7309265136719], [27.9772472381592, -82.8277816772461], [32.3483352661133, -97.3816604614258], [34.6911773681641, -82.8334808349609], [41.5044174194336, -81.6981735229492], [37.8117713928223, -79.8364944458008], [44.622127532959, -88.7601547241211], [38.7998962402344, -123.012077331543], [39.9856185913086, -75.8206634521484], [39.0994567871094, -120.952705383301], [46.8759269714355, -117.363655090332], [30.6003360748291, -96.3371276855469], [38.8319244384766, -104.819198608398], [33.9937171936035, -81.0405731201172], [32.4613342285156, -84.9874267578125], [39.9590797424316, -82.996696472168], [43.3406677246094, -89.0124816894531], [33.9909057617188, -118.143737792969], [40.0181007385254, -79.5925979614258], [39.6464653015137, -85.1335601806641], [33.8351249694824, -79.0467300415039], [32.9778442382813, -111.515518188477], [43.3666458129883, -124.211990356445], [36.0981941223145, -119.556503295898], [39.9284782409668, -122.196929931641], [40.071891784668, -74.9508056640625], [32.0916061401367, -96.4619598388672], [44.5652389526367, -123.260597229004], [43.8047409057617, -123.056396484375], [40.0442543029785, -86.8993835449219], [41.0570831298828, -94.361198425293], [30.7575874328613, -86.5690307617188], [41.1927299499512, -73.8838424682617], [38.4729232788086, -77.9930419921875], [39.6505851745605, -78.7584762573242], [48.6369400024414, -112.330024719238], [28.3641891479492, -82.1848220825195], [32.7755432128906, -96.8074035644531], [40.1194267272949, -87.636116027832], [36.5836982727051, -79.3843154907227], [41.5197372436523, -90.5774230957031], [38.5441131591797, -121.73706817627], [29.2282314300537, -81.0091171264648], [42.3130493164063, -83.2011795043945], [26.3177947998047, -80.1214599609375], [32.9594268798828, -117.266700744629], [29.3630809783936, -100.901466369629], [29.0168342590332, -81.3524551391602], [26.4551792144775, -80.092529296875], [32.2710838317871, -107.760833740234], [33.3261451721191, -81.1431503295898], [39.7532234191895, -104.999610900879], [39.858341217041, -104.666915893555], [42.3678817749023, -83.0720977783203], [46.8194885253906, -95.8455810546875], [48.1106452941895, -98.8613739013672], [34.418285369873, -79.3717575073242], [33.8105888366699, -117.922882080078], [37.7525978088379, -100.016578674316], [41.981201171875, -86.1087341308594], [40.0025367736816, -75.708122253418], [38.0113525390625, -89.2401580810547], [38.9516181945801, -77.4479141235352], [46.7666015625, -92.1240081787109], [42.4853324890137, -79.3310165405273], [41.2111740112305, -122.269973754883], [42.9097785949707, -83.9824371337891], [33.0737533569336, -89.8534851074219], [35.9970359802246, -78.9072265625], [41.0920486450195, -88.4283218383789], [41.4985275268555, -87.5181884765625], [39.650707244873, -106.833053588867], [37.69921875, -121.893501281738], [48.4439659118652, -113.218559265137], [42.7190818786621, -84.4935455322266], [44.8143768310547, -91.4999923706055], [47.8112945556641, -122.383071899414], [39.1191558837891, -88.5457153320313], [34.0725975036621, -118.042495727539], [31.7577247619629, -106.494888305664], [37.6785430908203, -119.752891540527], [40.1473999023438, -76.6145782470703], [41.680721282959, -85.9710540771484], [40.8368759155273, -115.753395080566], [46.9995765686035, -120.552757263184], [41.3700523376465, -82.0970077514648], [37.8406791687012, -122.290679931641], [38.4018516540527, -96.1855392456055], [47.3205947875977, -119.548645019531], [42.1211280822754, -80.0810394287109], [45.7803688049316, -87.0873565673828], [48.2808609008789, -113.609481811523], [44.0553855895996, -123.091842651367], [40.8030166625977, -124.158203125], [41.269214630127, -110.964294433594], [47.9792823791504, -122.215621948242], [31.4325218200684, -86.9561157226563], [40.0199508666992, -75.6232986450195], [43.590576171875, -73.2620468139648], [46.8810768127441, -96.7846145629883], [40.2415542602539, -88.642707824707], [35.0549049377441, -78.8850631713867], [34.3961296081543, -118.916610717773], [37.4746284484863, -119.637191772461], [35.1980133056641, -111.650665283203], [43.0136337280273, -83.6548385620117], [44.011360168457, -124.10034942627], [34.1988182067871, -79.7570953369141], [43.7555313110352, -88.4507904052734], [43.7525177001953, -88.4501876831055], [40.5837821960449, -105.06591796875], [43.2695159912109, -73.5804595947266], [31.1399593353271, -97.7643127441406], [26.1196136474609, -80.1701889038086], [40.6233940124512, -91.3333587646484], [40.2473297119141, -103.80265045166], [26.6823501586914, -81.8849029541016], [41.0760803222656, -85.1387023925781], [32.7493743896484, -97.3238677978516], [40.5974960327148, -124.151893615723], [41.1525344848633, -83.4142684936523], [41.4576606750488, -71.9719390869141], [39.9486961364746, -105.817367553711], [42.276668548584, -71.4178619384766], [38.7650184631348, -77.1705474853516], [39.411792755127, -77.4110641479492], [38.2985572814941, -77.4569320678711], [42.445125579834, -79.3401794433594], [37.5399322509766, -121.922439575195], [37.5581970214844, -122.006378173828], [36.7386283874512, -119.782249450684], [39.5871047973633, -106.096282958984], [33.8689460754395, -117.922836303711], [36.5225219726563, -88.8880081176758], [29.6510791778564, -82.3236923217773], [34.2837181091309, -83.8266830444336], [33.6244239807129, -97.140266418457], [40.9496192932129, -90.3710250854492], [40.9440498352051, -90.3641052246094], [35.5292472839355, -108.739677429199], [29.2912082672119, -94.7860717773438], [40.1010627746582, -123.793899536133], [37.9647254943848, -100.87279510498]]
    
    
    static let photos = [
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-HkGfPkX/1/XL/IMG_5575-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-pdBg3tS/1/XL/IMG_5578-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-pbDPBJj/1/XL/IMG_5582-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-d26VdXX/1/XL/IMG_5585-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-FXCg54L/1/XL/IMG_5660-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-K3jTkcB/1/XL/IMG_5683-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-TXFMNPx/1/XL/IMG_5684-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-5xBTRx7/1/XL/IMG_5691-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-gcJ7rQN/1/XL/IMG_5696-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-CRjSWZs/1/XL/IMG_5710-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-9CWvcNV/1/XL/IMG_5716-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-GZbj43q/1/XL/IMG_5734-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-rw3zbp7/1/XL/IMG_5742-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-TssS3qx/1/XL/IMG_5766-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-8LG5pQC/1/XL/IMG_1238-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-WG9jXdZ/0/XL/IMG_3491-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-FZTBT5D/0/XL/IMG_3489-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-ngRtG8k/1/XL/IMG_4645-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-km6R3N2/1/XL/IMG_4613-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-2MBtMCX/0/XL/IMG_0202-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-hZkxmvP/0/XL/IMG_9919-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-bz35Sbw/0/XL/IMG_3510-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-wmNzD2B/0/XL/IMG_3485-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-j6jzvVh/0/XL/IMG_1212-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-knZ7NK7/0/XL/IMG_1172-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-c7Hr6Vb/0/XL/IMG_9790-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-s6prns7/1/XL/IMG_9403-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-hLmXWCN/0/XL/IMG_8263-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-ZTCpNDH/1/XL/IMG_3740-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-3JzMJv2/0/XL/IMG_8062-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-jKw2Vqr/0/XL/IMG_7968-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-3hzqC4B/1/XL/IMG_7789-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-zNWf7FC/2/XL/IMG_7654-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-Z6vHDM5/1/XL/IMG_7489-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-MNsbCzJ/2/XL/IMG_6896-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-2JZF4hG/1/XL/IMG_6893-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-bTskkMW/2/XL/IMG_6889-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-G4M2pVL/1/XL/IMG_6305-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-jHtPZh3/1/XL/IMG_6275-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-T25B8nB/1/XL/IMG_6218-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-S69HbKX/1/XL/IMG_6082-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-G89pK9D/0/XL/IMG_8171-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-HMjM6QZ/1/XL/IMG_8121-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-CZ8FrNQ/2/XL/IMG_7459-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-LPBgBX9/3/XL/IMG_7436-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-M5tSNPG/0/XL/IMG_8445-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-fP9gWpq/0/XL/IMG_8363-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-fc2VBx8/0/XL/IMG_8348-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-ZSCXzXr/2/XL/IMG_4243-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-ZW6C64f/2/XL/IMG_4251-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-h9V99mZ/0/XL/IMG_1617-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-zpwjgFN/1/XL/IMG_9261-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-P4Z5dnm/1/XL/IMG_5372-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-BDv9Cd6/1/XL/IMG_5191-XL.jpg"]
    
    static let firstPagePhotos = [
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-HvFGwD3/1/XL/IMG_6086-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-nc4wxvh/1/XL/IMG_7762-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-7z5PhJV/1/XL/IMG_6081-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-WRmbDfK/0/XL/IMG_7463-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-tzxCS86/1/XL/IMG_8998-XL.jpg",
        "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-Mn6zwXm/1/XL/IMG_9000-XL.jpg"]


    static let firstPageCaptions = [
        "Castro theatre #sanfrancisco",
        "Awesome lunch at memphis minnies #bbq #food #pork #sanfrancisco",
        "Quaint bed and breakfast in #sanfrancisco #green #bedandbreakfast #charming",
        "Great day in #sausalito, can't wait to go sailing again #sunsets #boats #sailing",
        "No parking! Love the #graffiti in #hayesvalley full of #color #sanfrancisco",
        "Candy #sweets #color #hayesvalley #sanfrancisco"
    ]
    
    static let firstPageLocations = [
        [37.7619920,-122.4347360],
        [37.7721500,-122.4317120],
        [37.7671120,-122.4471910],
        [37.8590940,-122.4852510],
        [37.7759070,-122.4245250],
        [37.7878750,-122.4269130]
    ]
    

    static func GetData(){
        func random(min min: Int, max: Int) -> Int {
            return  Int(arc4random_uniform(UInt32(max))) + min
        }
        
        func isTag()->Bool{
            return random(min: 0, max: 2) >= 1
        }
        
        
        RequestManager.deleteAll()
        RequestManager.save()
        
        if let path = NSBundle.mainBundle().pathForResource("words", ofType: "txt"){
            let fm = NSFileManager()
            let exists = fm.fileExistsAtPath(path)
            if(exists){
                let contents = fm.contentsAtPath(path)
                let cString = NSString(data: contents!, encoding: NSUTF8StringEncoding)
                let string = cString as! String
                let terms = string.componentsSeparatedByString("\r").map() { $0.stringByReplacingOccurrencesOfString("\n", withString: "") }
                
                for i in 0 ..< photos.count{
                    let location = CLLocationCoordinate2D(latitude: locations[i][0], longitude: locations[i][1])
                    var caption = ""
                    for _ in 0 ..< Int(random(min: 5, max: 15)){
                        let term = terms[Int(random(min: 0,max: terms.count-1))]
                        let tag = isTag() ? "#" : ""
                        caption += tag + term + " "
                    }
                    
                    RequestManager.createNote(caption, photo: photos[i], location: location)
                    
                }
                RequestManager.save()
            }
        }
        
        
        for index in 0 ..< firstPageCaptions.count{
            let location = CLLocationCoordinate2D(latitude: firstPageLocations[index][0], longitude: firstPageLocations[index][1])
            RequestManager.createNote(firstPageCaptions[index], photo: firstPagePhotos[index], location: location)
        }
        
    }
}
