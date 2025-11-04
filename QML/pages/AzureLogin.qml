import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.7
import "../script.js" as Script

ApplicationWindow {
    id: azureLoginRoot
    width: 800
    height: 600
    property string accessToken: ""
    property string refreshToken: ""

    signal tokensReceived(string accessToken, string refreshToken)

    WebEngineView {
        id: webview
        anchors.fill: parent
        url: "https://backend-oversight.reak.co.in/api/oauth/azure/login"

        onLoadingChanged: {
            if (!webview.loading) {
                webview.runJavaScript("document.body.innerText", function(result) {
                    try {
                        var data = JSON.parse(result);
                        if (data.response === "success" && data.payload) {
                            var accessToken = data.payload.access_token;
                            var refreshToken = data.payload.refresh_token;

                            azureLoginRoot.accessToken = accessToken;
                            azureLoginRoot.refreshToken = refreshToken;

                            // console.log("Azure Access Token:", accessToken);
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
