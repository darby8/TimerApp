// import QtQuick
// import QtQuick.Controls
// import QtWebEngine
// import "../script.js" as Script

// ApplicationWindow {
//     id: googleLoginRoot
//     width: 800
//     height: 600
//     property string accessToken: ""
//     property string refreshToken: ""

//     signal tokensReceived(string accessToken, string refreshToken)

//     WebEngineView {
//         id: webview
//         anchors.fill: parent
//         url: "https://backend-oversight.reak.co.in/api/oauth/google/login"

//         // QML WebEngineView does not pass loadRequest, so just check webview.loading
//         onLoadingChanged: {
//             if (!webview.loading) {  // means load finished
//                 webview.runJavaScript("document.body.innerText", function(result) {
//                     try {
//                         var data = JSON.parse(result);
//                         if (data.response === "success" && data.payload) {
//                             mainWindow.loggedIn=true;
//                             var accessToken = data.payload.access_token;
//                             var refreshToken = data.payload.refresh_token;
//                             appSettings.accessToken=accessToken
//                             googleLoginRoot.accessToken = accessToken;
//                             googleLoginRoot.refreshToken = refreshToken;
//                             tracker.setAccessToken(accessToken);

//                             // console.log("Access Token:--------------------", accessToken);
//                             googleLoginRoot.tokensReceived(accessToken, refreshToken);
//                             globalLoader.showLoader();
//                             googleLoginRoot.visible = false;

//                             Script.fetchUserProfile(tracker.getAccessToken)
//                         }
//                     } catch (e) {
//                         console.error("Page content is not valid JSON or not ready:", e);
//                     }
//                 });
//             }
//         }
//     }
// }






import QtQuick
import QtQuick.Controls
import QtWebEngine
import "../script.js" as Script

ApplicationWindow {
    id: googleLoginRoot
    width: 800
    height: 600

    property string accessToken: ""
    property string refreshToken: ""

    signal tokensReceived(string accessToken, string refreshToken)

    // -----------------------------------------------------------
    // 🔥 Lightweight profile to reduce memory usage
    // -----------------------------------------------------------
    WebEngineProfile {
        id: liteProfile
        offTheRecord: true
        httpCacheType: WebEngineProfile.NoCache
        persistentCookiesPolicy: WebEngineProfile.NoPersistentCookies
    }

    WebEngineView {
        id: webview
        anchors.fill: parent
        profile: liteProfile      // IMPORTANT: attaches low-RAM profile
        url: "https://backend-oversight.reak.co.in/api/oauth/google/login"

        // -----------------------------------------------------------
        // 🔥 Disable heavy Chromium features (RAM saver)
        // -----------------------------------------------------------
        settings {
            webGLEnabled: false
            accelerated2dCanvasEnabled: false
            allowRunningInsecureContent: false
            javascriptCanOpenWindows: true    // Google OAuth requires popup redirects
            autoLoadImages: true
        }

        // -----------------------------------------------------------
        // 100% Same functionality – unchanged logic
        // -----------------------------------------------------------
        onLoadingChanged: {
            if (!webview.loading) {
                webview.runJavaScript("document.body.innerText", function(result) {
                    try {
                        var data = JSON.parse(result);

                        if (data.response === "success" && data.payload) {

                            mainWindow.loggedIn = true;

                            var accessToken = data.payload.access_token;
                            var refreshToken = data.payload.refresh_token;
                            appSettings.accessToken=accessToken
                            appSettings.accessToken = accessToken
                            googleLoginRoot.accessToken = accessToken;
                            googleLoginRoot.refreshToken = refreshToken;

                            tracker.setAccessToken(accessToken);

                            googleLoginRoot.tokensReceived(accessToken, refreshToken);

                            globalLoader.showLoader();
                            googleLoginRoot.visible = false;

                            Script.fetchUserProfile(tracker.getAccessToken);
                        }
                    } catch (e) {
                        console.error("Page content is not valid JSON or not ready:", e);
                    }
                });
            }
        }
    }
}

