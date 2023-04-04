"use strict";
export const INTERNAL_APP_NAME = "Antipacman"
export const YA_LOCAL_STORAGE_KEY_DATA = INTERNAL_APP_NAME + ".yagames.data";
export const YA_LOCAL_STORAGE_KEY_NUMERIC = INTERNAL_APP_NAME + ".yagames.numeric.data";
export const YA_PREMIUM_PURCHASE_ID = INTERNAL_APP_NAME + "_premium_account";
export const LEADERBOARD_NAME = "BestResults";

export function createDefaultGameData() {
    return {
        bestScore: 0,
        language: "ru",
        userSelectedLanguage: "",
        musicOn: true,
        soundOn: true,
        maxGameLevel: 1,
        savedGameLevel: 1,
        killedFoesAll: 0,
        aesculapiAll: 0,
        wheatEarAll: 0,
        lilacSpheresAll: 0,
        pepperAll: 0,
        portalsAll: 0,
        timeSpentAll: 0,
        tutorialShown: false,
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
        bestScore: Math.max(local_data.bestScore, remote_data.bestScore),
        language: remote_data.language,
        userSelectedLanguage: local_data.language,
        musicOn: local_data.musicOn,
        soundOn: local_data.soundOn,
        maxGameLevel: Math.max(local_data.maxGameLevel, remote_data.maxGameLevel),
        savedGameLevel: Math.max(local_data.savedGameLevel, remote_data.savedGameLevel),
        killedFoesAll: Math.max(local_data.killedFoesAll, remote_data.killedFoesAll),
        aesculapiAll: Math.max(local_data.aesculapiAll, remote_data.aesculapiAll),
        wheatEarAll: Math.max(local_data.wheatEarAll, remote_data.wheatEarAll),
        lilacSpheresAll: Math.max(local_data.lilacSpheresAll, remote_data.lilacSpheresAll),
        pepperAll: Math.max(local_data.pepperAll, remote_data.pepperAll),
        portalsAll: Math.max(local_data.portalsAll, remote_data.portalsAll),
        timeSpentAll: Math.max(local_data.timeSpentAll, remote_data.timeSpentAll),
        tutorialShown: local_data.tutorialShown || remote_data.tutorialShown,
    };
}
