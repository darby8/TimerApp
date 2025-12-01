// import QtQuick
// import QtQuick.Controls
// import QtWebEngine
// import "../script.js" as Script

// ApplicationWindow {
//     id: azureLoginRoot
//     width: 800
//     height: 600
//     property string accessToken: ""
//     property string refreshToken: ""

//     signal tokensReceived(string accessToken, string refreshToken)

//     WebEngineView {
//         id: webview
//         anchors.fill: parent
//         url: "https://backend-oversight.reak.co.in/api/oauth/azure/login"

//         onLoadingChanged: {
//             if (!webview.loading) {
//                 webview.runJavaScript("document.body.innerText", function(result) {
//                     try {
//                         var data = JSON.parse(result);
//                         if (data.response === "success" && data.payload) {
//                             mainWindow.loggedIn = true;
//                             var accessToken = data.payload.access_token;
//                             var refreshToken = data.payload.refresh_token;
//                             appSettings.accessToken=accessToken
//                             azureLoginRoot.accessToken = accessToken;
//                             azureLoginRoot.refreshToken = refreshToken;

//                             // console.log("Azure Access Token:", accessToken);
//                             azureLoginRoot.tokensReceived(accessToken, refreshToken);
//                             tracker.setAccessToken(accessToken);
//                             globalLoader.showLoader();
//                             azureLoginRoot.visible = false;

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
    id: azureLoginRoot
    width: 800
    height: 600

    property string accessToken: ""
    property string refreshToken: ""

    signal tokensReceived(string accessToken, string refreshToken)

    // -----------------------------------------------------------
    // 🔥 Use a lightweight shared profile (major memory reduction)
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
        profile: liteProfile   // << IMPORTANT: uses low-memory profile
        url: "https://backend-oversight.reak.co.in/api/oauth/azure/login"
        settings {
            webGLEnabled: false
            accelerated2dCanvasEnabled: false
            allowRunningInsecureContent: false
            javascriptCanOpenWindows: true   // REQUIRED for OAuth redirect
            autoLoadImages: true
        }
        onLoadingChanged: {
            if (!webview.loading) {
                webview.runJavaScript("document.body.innerText", function(result) {
                    try {
                        var data = JSON.parse(result);

                        if (data.response === "success" && data.payload) {

                            var accessToken = data.payload.access_token;
                            var refreshToken = data.payload.refresh_token;
                            appSettings.accessToken=accessToken
                            azureLoginRoot.accessToken = accessToken;
                            azureLoginRoot.refreshToken = refreshToken;

                            azureLoginRoot.tokensReceived(accessToken, refreshToken);

                            tracker.setAccessToken(accessToken);
                            globalLoader.showLoader();

                            azureLoginRoot.visible = false;
                            mainWindow.loggedIn = true;

                            Script.fetchUserProfile(tracker.getAccessToken)
                        }
                    } catch (e) {
                        console.error("Page content is not valid JSON or not ready:", e);
                    }
                });
            }
        }
    }
}
