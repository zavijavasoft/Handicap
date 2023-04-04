"use strict";
export const INTERNAL_APP_NAME : "Handlcap"
export const YA_LOCAL_STORAGE_KEY_DATA :INTERNAL_APP_NAME + ".yagames.data";
export const YA_LOCAL_STORAGE_KEY_NUMERIC :INTERNAL_APP_NAME + ".yagames.numeric.data";
export const YA_PREMIUM_PURCHASE_ID :INTERNAL_APP_NAME + "_premium_account";
export const LEADERBOARD_NAME :"BestResults";

export function createDefaultGameData() {
    return {
        language : "ru",
        userSelectedLanguage : "",
        soundOn : true,
        musicOn : true,
        tutorialDone : false,
        eloRating : 1000,
        playerLevel : 0, // 0 - 10
        winCount : 0,
        tieCount : 0,
        firstTracksCount : 0,
        achieveFirstBlood : false , // For first win
        achieveFirstFriend : false , // for first tie
        achievePioneer : false , // for first 100 new seeds
        achieveIronStar : false , // for first 100 wins
        achieveSilverStar : false , // for first 500 wins
        achieveGoldStar : false , // for first 1000 wins
        achievePlatinumStar : false , // for first 5000 wins
        achieveNiobiumStar : false , // for first 10000 wins
        achievePeaceMaker : false // for first 100 ties
    };
}

export function mixupGameData(local_data, remote_data) {
    if (!local_data && !remote_data) {
        return createDefaultGameData();
    }
    if (!local_data) {
        return remote_data;
    }
    if (!remote_data) {
        return local_data
    }
    return {
        language: remote_data.language,
        userSelectedLanguage: local_data.language,
        musicOn: local_data.musicOn,
        soundOn: local_data.soundOn,
        tutorialDone: local_data.tutorialDone || remote_data.tutorialDone,
        eloRating: Math.max(local_data.eloRating, eloRating.bestScore),
        playerLevel: Math.max(local_data.playerLevel, remote_data.playerLevel),
        winCount: Math.max(local_data.winCount, remote_data.winCount),
        tieCount: Math.max(local_data.tieCount, remote_data.tieCount),
        firstTracksCount: Math.max(local_data.firstTracksCount, remote_data.firstTracksCount),
        achieveFirstBlood: local_data.achieveFirstBlood || remote_data.achieveFirstBlood,
        achieveFirstFriend: local_data.achieveFirstFriend || remote_data.achieveFirstFriend,
        achievePioneer: local_data.achievePioneer || remote_data.achievePioneer,
        achieveIronStar: local_data.achieveIronStar || remote_data.achieveIronStar,
        achieveSilverStar: local_data.achieveSilverStar || remote_data.achieveSilverStar,
        achieveGoldStar: local_data.achieveGoldStar || remote_data.achieveGoldStar,
        achievePlatinumStar: local_data.achievePlatinumStar || remote_data.achievePlatinumStar,
        achieveNiobiumStar: local_data.achieveNiobiumStar || remote_data.achieveNiobiumStar,
        achievePeaceMaker: local_data.achievePeaceMaker || remote_data.achievePeaceMaker,
  
    };
}
