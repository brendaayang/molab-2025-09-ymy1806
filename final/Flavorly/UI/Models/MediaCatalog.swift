//
//  MediaCatalog.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation

enum MediaCategory: String, CaseIterable {
    case snowStrippers = "Snow Strippers"
    case nightcore = "Nightcore"
    case slowedReverb = "Slowed + Reverb"
    case fakemink = "Fakemink"
    case twohollis = "2hollis"
    case classicElectronic = "Classic Electronic"
    case hyperpop = "Hyperpop"
    case hipHop = "Hip Hop"
    case popHits = "Pop Hits"
    case allSongs = "All Songs"
    
    var displayName: String {
        return self.rawValue
    }
}

enum MediaItem: CaseIterable {
    // Snow Strippers
    case snowStrippersSabotage
    case snowStrippersPassionateHighs
    case snowStrippersPassionateHighsSlowedReverb
    case snowStrippersPassionateHighsSlowedReverbAlt
    case snowStrippersTimeWarpAngelsSlowedReverb
    case backInBloodSnowStrippersRemix
    case christianDiorDenimFlowSnowStrippersRemix
    
    // Nightcore
    case nightcoreTilDeath
    case nightcoreKissMeAgainAroundTheWorld
    
    // Slowed + Reverb
    case suicidalIdolEcstacySlowed
    
    // Electronic / Classics
    case davidGuettaSexyChick
    case discotronicTrickyDisco
    case edwardMayaStereoLove
    case psyGangnamStyle
    
    // Hyperpop / Alternative
    case sixarelyhumanHandsUp
    case nxghtLxvixVaitoEsaVei
    
    // MP3 Only (from original set)
    case ecstacy
    case kiss
    case under
    case lacerate
    case passion
    
    // New additions from Media folder
    // 2hollis
    case twohollisGold
    case twohollisPosterBoy
    
    // Alexandra Stan
    case alexandraStanMrSaxobeat
    
    // Bass/Electronic
    case bassSlutOriginal
    case betterOffABassSlxt
    case buckshotFakeminkFever
    
    // Various artists
    case candy
    case cantFightThisFeelingNightcore
    case casperTngFreeze
    case closer
    case fengXoxo
    case innaHot
    case lacerateVideo
    case painBrings
    case secretSomewhereSpecial
    case snowStrippersAchingLikeIts
    case soHigh
    case suicidalIdolXoxo
    
    // Fakemink
    case fakeminkEasterPink
    case fakeminkMusicAndMe
    case fakeminkSnowWhite
    
    // Additional new files from Media folder
    case modernTalkingYoureMyHeartYoureMySoul
    case enriqueIglesiasUsherLilWayneDirtyDancer
    case esdeekidFakeminkRicoAceLvSandals
    case esdeekidRicoAcePhantom
    case pitbullGiveMeEverything
    
    var displayTitle: String {
        switch self {
        case .snowStrippersSabotage: return "Sabotage"
        case .snowStrippersPassionateHighs: return "Passionate Highs"
        case .snowStrippersPassionateHighsSlowedReverb: return "Passionate Highs (Slowed)"
        case .snowStrippersPassionateHighsSlowedReverbAlt: return "Passionate Highs (Slowed Alt)"
        case .snowStrippersTimeWarpAngelsSlowedReverb: return "Time Warp Angels (Slowed)"
        case .backInBloodSnowStrippersRemix: return "Back In Blood (Remix)"
        case .christianDiorDenimFlowSnowStrippersRemix: return "Christian Dior Denim Flow"
        case .nightcoreTilDeath: return "Til Death"
        case .nightcoreKissMeAgainAroundTheWorld: return "Kiss Me Again X Around The World"
        case .suicidalIdolEcstacySlowed: return "ecstacy (slowed)"
        case .davidGuettaSexyChick: return "Sexy Chick"
        case .discotronicTrickyDisco: return "Tricky Disco"
        case .edwardMayaStereoLove: return "Stereo Love"
        case .psyGangnamStyle: return "Gangnam Style"
        case .sixarelyhumanHandsUp: return "Hands up!"
        case .nxghtLxvixVaitoEsaVei: return "ESA VEI"
        case .ecstacy: return "ecstacy"
        case .kiss: return "Kiss Me Again"
        case .under: return "Under a Seige"
        case .lacerate: return "Lacerate"
        case .passion: return "Passionate Highs"
        
        // New additions display titles
        case .twohollisGold: return "gold"
        case .twohollisPosterBoy: return "poster boy"
        case .alexandraStanMrSaxobeat: return "Mr. Saxobeat"
        case .bassSlutOriginal: return "Bass Slut"
        case .betterOffABassSlxt: return "Better Off A Bass Slxt"
        case .buckshotFakeminkFever: return "Fever"
        case .candy: return "Candy"
        case .cantFightThisFeelingNightcore: return "Can't Fight This Feeling"
        case .casperTngFreeze: return "Freeze"
        case .closer: return "Closer"
        case .fengXoxo: return "XOXO"
        case .innaHot: return "Hot"
        case .lacerateVideo: return "Lacerate"
        case .painBrings: return "Pain Brings"
        case .secretSomewhereSpecial: return "Somewhere Special"
        case .snowStrippersAchingLikeIts: return "Aching Like It's"
        case .soHigh: return "So High"
        case .suicidalIdolXoxo: return "xoxo"
        case .fakeminkEasterPink: return "Easter Pink"
        case .fakeminkMusicAndMe: return "Music and Me"
        case .fakeminkSnowWhite: return "Snow White"
        
        // Additional new files display titles
        case .modernTalkingYoureMyHeartYoureMySoul: return "You're My Heart, You're My Soul"
        case .enriqueIglesiasUsherLilWayneDirtyDancer: return "Dirty Dancer"
        case .esdeekidFakeminkRicoAceLvSandals: return "LV Sandals"
        case .esdeekidRicoAcePhantom: return "Phantom"
        case .pitbullGiveMeEverything: return "Give Me Everything"
        }
    }
    
    var artist: String {
        switch self {
        case .snowStrippersSabotage, .snowStrippersPassionateHighs,
             .snowStrippersPassionateHighsSlowedReverb, .snowStrippersPassionateHighsSlowedReverbAlt,
             .snowStrippersTimeWarpAngelsSlowedReverb,
             .backInBloodSnowStrippersRemix, .christianDiorDenimFlowSnowStrippersRemix:
            return "Snow Strippers"
        case .nightcoreTilDeath, .nightcoreKissMeAgainAroundTheWorld:
            return "Nightcore"
        case .suicidalIdolEcstacySlowed:
            return "SUICIDAL-IDOL"
        case .davidGuettaSexyChick:
            return "David Guetta ft. Akon"
        case .discotronicTrickyDisco:
            return "Discotronic"
        case .edwardMayaStereoLove:
            return "Edward Maya & Vika Jigulina"
        case .psyGangnamStyle:
            return "PSY"
        case .sixarelyhumanHandsUp:
            return "6arelyhuman ft. kets4eki"
        case .nxghtLxvixVaitoEsaVei:
            return "NXGHT!, lxvix & VAITO"
        case .ecstacy:
            return "SUICIDAL-IDOL"
        case .kiss:
            return "Roy Bee"
        case .under:
            return "Snow Strippers"
        case .lacerate:
            return "Snow Strippers"
        case .passion:
            return "Snow Strippers"
            
        // New additions artists
        case .twohollisGold, .twohollisPosterBoy:
            return "2hollis"
        case .alexandraStanMrSaxobeat:
            return "Alexandra Stan"
        case .bassSlutOriginal:
            return "S3RL"
        case .betterOffABassSlxt:
            return "lavendr"
        case .buckshotFakeminkFever:
            return "BUCKSHOT & FAKEMINK"
        case .candy:
            return "Snow Strippers"
        case .cantFightThisFeelingNightcore:
            return "Junior Caldera"
        case .casperTngFreeze:
            return "Casper TNG ft Top 5"
        case .closer:
            return "Gaskin"
        case .fengXoxo:
            return "Feng"
        case .innaHot:
            return "Inna"
        case .lacerateVideo:
            return "Snow Strippers"
        case .painBrings:
            return "Snow Strippers (UNRELEASED)"
        case .secretSomewhereSpecial:
            return "Somewhere Special"
        case .snowStrippersAchingLikeIts:
            return "Snow Strippers"
        case .soHigh:
            return "David Deejay"
        case .suicidalIdolXoxo:
            return "SUICIDAL-IDOL"
        case .fakeminkEasterPink, .fakeminkMusicAndMe, .fakeminkSnowWhite:
            return "fakemink"
            
        // Additional new files artists
        case .modernTalkingYoureMyHeartYoureMySoul:
            return "Modern Talking"
        case .enriqueIglesiasUsherLilWayneDirtyDancer:
            return "Enrique Iglesias ft. Usher & Lil Wayne"
        case .esdeekidFakeminkRicoAceLvSandals:
            return "EsDeeKid ft. Fakemink & Rico Ace"
        case .esdeekidRicoAcePhantom:
            return "EsDeeKid & Rico Ace"
        case .pitbullGiveMeEverything:
            return "Pitbull ft. Ne-Yo, Afrojack & Nayer"
        }
    }
    
    var fileName: String {
        switch self {
        case .snowStrippersSabotage: return "snow_strippers_sabotage.mp4"
        case .snowStrippersPassionateHighs: return "snow_strippers_passionate_highs.mp4"
        case .snowStrippersPassionateHighsSlowedReverb: return "snow_strippers_passionate_highs_slowed_reverb.mp4"
        case .snowStrippersPassionateHighsSlowedReverbAlt: return "snow_strippers_passionate_highs_slowed_reverb_alt.mp4"
        case .snowStrippersTimeWarpAngelsSlowedReverb: return "snow_strippers_time_warp_angels_slowed_reverb.mp4"
        case .backInBloodSnowStrippersRemix: return "back_in_blood_snow_strippers_remix.mp4"
        case .christianDiorDenimFlowSnowStrippersRemix: return "christian_dior_denim_flow_snow_strippers_remix.mp4"
        case .nightcoreTilDeath: return "nightcore_til_death.mp4"
        case .nightcoreKissMeAgainAroundTheWorld: return "nightcore_kiss_me_again_around_the_world.mp4"
        case .suicidalIdolEcstacySlowed: return "suicidal_idol_ecstacy_slowed.mp4"
        case .davidGuettaSexyChick: return "david_guetta_sexy_chick.mp4"
        case .discotronicTrickyDisco: return "discotronic_tricky_disco.mp4"
        case .edwardMayaStereoLove: return "edward_maya_stereo_love.mp4"
        case .psyGangnamStyle: return "psy_gangnam_style.mp4"
        case .sixarelyhumanHandsUp: return "6arelyhuman_hands_up.mp4"
        case .nxghtLxvixVaitoEsaVei: return "nxght_lxvix_vaito_esa_vei.mp4"
        case .ecstacy: return "ecstacy.mp3"
        case .kiss: return "kiss.mp3"
        case .under: return "under.mp3"
        case .lacerate: return "lacerate.mp3"
        case .passion: return "passion.mp3"
        
        // New additions file names
        case .twohollisGold: return "2hollis_gold.mp4"
        case .twohollisPosterBoy: return "2hollis_poster_boy.mp4"
        case .alexandraStanMrSaxobeat: return "alexandra_stan_mr_saxobeat.mp4"
        case .bassSlutOriginal: return "bass_slut_original.mp4"
        case .betterOffABassSlxt: return "better_off_a_bass_slxt.mp4"
        case .buckshotFakeminkFever: return "buckshot_fakemink_fever.mp4"
        case .candy: return "candy.mp4"
        case .cantFightThisFeelingNightcore: return "cant_fight_this_feeling_nightcore.mp4"
        case .casperTngFreeze: return "casper_tng_freeze.mp4"
        case .closer: return "closer.mp4"
        case .fengXoxo: return "feng_xoxo.mp4"
        case .innaHot: return "inna_hot.mp4"
        case .lacerateVideo: return "lacerate_video.mp4"
        case .painBrings: return "pain_brings.mp4"
        case .secretSomewhereSpecial: return "secret_somewhere_special.mp4"
        case .snowStrippersAchingLikeIts: return "snow_strippers_aching_like_its.mp4"
        case .soHigh: return "so_high.mp4"
        case .suicidalIdolXoxo: return "suicidal_idol_xoxo.mp4"
        case .fakeminkEasterPink: return "fakemink_easter_pink.mp4"
        case .fakeminkMusicAndMe: return "fakemink_music_and_me.mp4"
        case .fakeminkSnowWhite: return "fakemink_snow_white.mp4"
        
        // Additional new files file names
        case .modernTalkingYoureMyHeartYoureMySoul: return "modern_talking_youre_my_heart_youre_my_soul.mp4"
        case .enriqueIglesiasUsherLilWayneDirtyDancer: return "enrique_iglesias_usher_lil_wayne_dirty_dancer.mp4"
        case .esdeekidFakeminkRicoAceLvSandals: return "esdeekid_fakemink_rico_ace_lv_sandals.mp4"
        case .esdeekidRicoAcePhantom: return "esdeekid_rico_ace_phantom.mp4"
        case .pitbullGiveMeEverything: return "pitbull_give_me_everything.mp4"
        }
    }
    
    var category: MediaCategory {
        switch self {
        // Snow Strippers - All Snow Strippers tracks
        case .snowStrippersSabotage, .snowStrippersPassionateHighs, .backInBloodSnowStrippersRemix, 
             .christianDiorDenimFlowSnowStrippersRemix, .snowStrippersAchingLikeIts, .candy:
            return .snowStrippers
            
        // Nightcore - Electronic remix style with sped-up vocals
        case .nightcoreTilDeath, .nightcoreKissMeAgainAroundTheWorld, .cantFightThisFeelingNightcore:
            return .nightcore
            
        // Slowed + Reverb - Slowed down tracks with reverb effects
        case .snowStrippersPassionateHighsSlowedReverb, .snowStrippersPassionateHighsSlowedReverbAlt,
             .snowStrippersTimeWarpAngelsSlowedReverb, .suicidalIdolEcstacySlowed, .ecstacy, 
             .lacerate, .lacerateVideo, .suicidalIdolXoxo:
            return .slowedReverb
            
        // Fakemink - Dedicated category for Fakemink tracks
        case .fakeminkEasterPink, .fakeminkMusicAndMe, .fakeminkSnowWhite, .buckshotFakeminkFever,
             .esdeekidFakeminkRicoAceLvSandals:
            return .fakemink
            
        // SUICIDAL-IDOL tracks moved to Slowed + Reverb
        case .suicidalIdolEcstacySlowed, .suicidalIdolXoxo, .ecstacy:
            return .slowedReverb
            
        // 2hollis - Dedicated category for 2hollis tracks
        case .twohollisGold, .twohollisPosterBoy:
            return .twohollis
            
        // Classic Electronic - Classic electronic hits
        case .davidGuettaSexyChick, .discotronicTrickyDisco, .edwardMayaStereoLove, 
             .alexandraStanMrSaxobeat, .innaHot, .bassSlutOriginal, .betterOffABassSlxt, 
             .casperTngFreeze, .soHigh, .modernTalkingYoureMyHeartYoureMySoul:
            return .classicElectronic
            
        // Hyperpop - Modern hyperpop artists
        case .sixarelyhumanHandsUp, .nxghtLxvixVaitoEsaVei, .fengXoxo:
            return .hyperpop
            
        // Hip Hop - Hip hop and rap tracks
        case .esdeekidRicoAcePhantom:
            return .hipHop
            
        // Pop Hits - Mainstream pop songs
        case .enriqueIglesiasUsherLilWayneDirtyDancer, .pitbullGiveMeEverything, .psyGangnamStyle:
            return .popHits
            
        // Alternative/Indie - Remaining tracks
        case .closer, .painBrings, .secretSomewhereSpecial, .kiss, .under, .passion:
            return .hyperpop // Grouping these with hyperpop for now
        }
    }
    
    var hasVideo: Bool {
        return fileName.hasSuffix(".mp4")
    }
    
    var fileExtension: String {
        return hasVideo ? "mp4" : "mp3"
    }
    
    // Get all media items for a specific category
    static func items(for category: MediaCategory) -> [MediaItem] {
        if category == .allSongs {
            return MediaItem.allCases
        }
        return MediaItem.allCases.filter { $0.category == category }
    }
    
    // Get media URL from bundle
    func getURL() -> URL? {
        let fileName = self.fileName
        let name = fileName.replacingOccurrences(of: ".\(fileExtension)", with: "")
        
        print("🔍 MediaCatalog: Looking for resource '\(name)' with extension '\(fileExtension)' in subdirectory 'Media'")
        
        // Try with subdirectory first
        if let url = Bundle.main.url(forResource: name, withExtension: fileExtension, subdirectory: "Media") {
            print("✅ MediaCatalog: Found in Media subdirectory: \(url)")
            return url
        }
        
        // Try without subdirectory
        if let url = Bundle.main.url(forResource: name, withExtension: fileExtension) {
            print("✅ MediaCatalog: Found in main bundle: \(url)")
            return url
        }
        
        // Try with Assets directory
        if let url = Bundle.main.url(forResource: name, withExtension: fileExtension, subdirectory: "Assets/Media") {
            print("✅ MediaCatalog: Found in Assets/Media: \(url)")
            return url
        }
        
        print("❌ MediaCatalog: File not found: \(fileName)")
        return nil
    }
}

