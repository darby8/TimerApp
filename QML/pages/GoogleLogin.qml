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

    WebEngineView {
        id: webview
        anchors.fill: parent
        url: "https://backend-oversight.reak.co.in/api/oauth/google/login"

        // QML WebEngineView does not pass loadRequest, so just check webview.loading
        onLoadingChanged: {
            if (!webview.loading) {  // means load finished
                webview.runJavaScript("document.body.innerText", function(result) {
                    try {
                        var data = JSON.parse(result);
                        if (data.response === "success" && data.payload) {
                            var accessToken = data.payload.access_token;
                            var refreshToken = data.payload.refresh_token;

                            googleLoginRoot.accessToken = accessToken;
                            googleLoginRoot.refreshToken = refreshToken;
                            tracker.setAccessToken(accessToken);

                            // console.log("Access Token:", accessToken);
                            googleLoginRoot.tokensReceived(accessToken, refreshToken);

                            // If you want to close after login:
                            globalLoader.showLoader();
                            googleLoginRoot.visible = false;
                            mainWindow.loggedIn=true
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
