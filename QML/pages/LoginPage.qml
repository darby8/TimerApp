import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../script.js" as Script


Item {
    Rectangle{
        id: loginPage
        width: Math.max(Math.min(parent.width * 0.85, 550), 350)
        height: Math.min(parent.height * 0.85, 520)
        // height: Math.min(parent.height * 0.70, 500) // max 500px tall
        radius: 16
        color: Theme.bg
        border.color: Theme.softgray
        border.width: 1
        anchors.centerIn: parent
        property real dynamicMargin: width < 300 ? 8 : 15
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            Layout.alignment: Qt.AlignHCenter

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8
                Image {
                    source: "../../icons/pulse.svg" // Substitute if you have an icon file
                    width: 25; height:25
                    sourceSize.width: width * Screen.devicePixelRatio
                    sourceSize.height: height * Screen.devicePixelRatio
                    smooth: true

                }
                Text {
                    text: Theme.appTitle
                    font.bold: true
                    font.pixelSize: width < 300 ? 22 : 35
                    color: text

                }
            }

            Label {
                text: Theme.signin
                font.pixelSize: width < 300 ? 13 : 16
                color: Theme.smalltxt
                Layout.alignment: Qt.AlignHCenter
            }

            // Social logins
            ColumnLayout {
                spacing: 12
                Layout.alignment: Qt.AlignHCenter
                // Google Button
                Rectangle {
                    Layout.fillWidth: true   // fills available space in column
                    // Layout.leftMargin: 10    // ✅ adds margin from left
                    Layout.rightMargin: 10
                    height: 35
                    radius: 5
                    color: Theme.bg
                    border.color: Theme.softgray
                    border.width: 1

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 16
                        spacing: 15
                        Image {
                            source: "../../icons/google.svg"
                            width: 20; height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize.height: height * Screen.devicePixelRatio
                            smooth: true
                        }
                        Text {
                            text: Theme.loginwithgoogletext
                            color: "black"
                            font.pixelSize: width < 300 ? 15 : 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var component = Qt.createComponent("GoogleLogin.qml");
                            if (component.status === Component.Ready) {
                                var oauthWindow = component.createObject(mainWindow);
                                if (oauthWindow) {
                                    oauthWindow.visible = true;  // <-- show() ki jagah visible = true
                                } else {
                                    console.error("Failed to create GoogleLogin window");
                                }
                            } else {
                                console.error("Component error:", component.errorString());
                            }
                        }
                    }

                }


                // Microsoft Button
                Rectangle {
                    Layout.fillWidth: true   // fills available space in column
                    // Layout.leftMargin: 10    // ✅ adds margin from left
                    Layout.rightMargin: 10
                    height: 35
                    radius: 5
                    color: Theme.microsoft
                    border.color: Theme.microsoft
                    border.width: 1

                    Row {
                        // anchors.fill: parent
                        anchors.leftMargin: 16
                        spacing: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            source: "../../icons/microsoft.svg"
                            width: 20; height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize.height: height * Screen.devicePixelRatio
                            smooth: true
                        }
                        Text {
                            text:Theme.loginwithmicrosofttext
                            color: Theme.bg
                            font.pixelSize: 15
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var component = Qt.createComponent("AzureLogin.qml");
                            if (component.status === Component.Ready) {
                                var oauthWindow = component.createObject(mainWindow);
                                if (oauthWindow) {
                                    oauthWindow.visible = true;  // <-- show() ki jagah visible = true
                                } else {
                                    console.error("Failed to create GoogleLogin window");
                                }
                            } else {
                                console.error("Component error:", component.errorString());
                            }
                        }
                    }
                }
            }


            // Separator with text
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
                spacing: 8
                Rectangle { color: Theme.softgray; height: 2; width: 120 }
                Label { text: "Or continue with email"; font.pixelSize: 14; color: Theme.smalltxt}
                Rectangle { color: Theme.softgray; height: 2; width: 120 }
            }

            // Email/password form
            ColumnLayout {
                spacing: 7
                Layout.alignment: Qt.AlignHCenter
                Label {
                    text: "Email";
                    font.pixelSize: 14;
                    color: "black"
                }

                Item {
                    Layout.fillWidth: true   // fills available space in column
                    // Layout.leftMargin: 10   // ✅ adds margin from left
                    Layout.rightMargin: 10
                    height: 35

                    // Background with border
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Theme.logininput
                        border.color: Theme.softgray
                        border.width: 1
                    }

                    // Icon inside the input, placed absolutely
                    Image {
                        source: "../../icons/email.svg"
                        width: 20; height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        sourceSize.height: height * Screen.devicePixelRatio
                        smooth: true
                    }

                    // TextField overlaying the background, left padding for the icon
                    TextField {
                        id: emailInput
                        anchors.fill: parent
                        leftPadding: 38                // Padding should be icon width + margin
                        font.pixelSize: 12
                        placeholderText: "Enter your email"
                        color: "black"
                        background: null                // Use our Rectangle, not default background
                    }
                }

                Label {
                    text: "Password";
                    font.pixelSize: 15;
                    color: "black"
                }

                Item {
                    Layout.fillWidth: true   // fills available space in column
                    // Layout.leftMargin: 10    // ✅ adds margin from left
                    Layout.rightMargin: 10
                    height: 35

                    // Background with border
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Theme.logininput
                        border.color: Theme.softgray
                        border.width: 1
                    }

                    // Icon inside the input, left side
                    Image {
                        source: "../../icons/eye.svg"
                        width: 20; height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        sourceSize.height: height * Screen.devicePixelRatio
                        smooth: true
                    }
                    TextField {
                        id: passwordInput
                        anchors.fill: parent
                        leftPadding: 38                    // Icon at left
                        rightPadding: 36                   // Space for eye button at right
                        font.pixelSize: 12
                        placeholderText: "Password"
                        color: "black"
                        echoMode: TextInput.Password
                        background: null
                        onAccepted: {
                            if (signInButton.enabled)
                                signInButton.signInAction()
                        }
                    }
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        Button {
                            icon.source: "../../icons/eye.svg"
                            background: Rectangle { color: "transparent" }
                            onClicked: passwordInput.echoMode === TextInput.Password ?
                                           passwordInput.echoMode = TextInput.Normal :
                                           passwordInput.echoMode = TextInput.Password
                        }
                    }
                }


                Rectangle {
                    id: signInButton
                    Layout.fillWidth: true   // fills available space in column
                    // Layout.leftMargin: 10    // ✅ adds margin from left
                    Layout.rightMargin: 10
                    height: 35
                    Layout.topMargin: 15
                    radius: 5
                    activeFocusOnTab: true
                    border.color: Theme.softgray
                    border.width: 1
                    enabled: emailInput.text.length > 0 && passwordInput.text.length > 0  //&& Script.isValidGmail(emailInput.text)

                    color: enabled ? Theme.microsoft : Theme.txtcolor
                    Row {
                        anchors.leftMargin: 16
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: "Sign In"
                            color: Theme.bg
                            font.pixelSize: 15
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: parent.enabled
                        onClicked: {
                            if (!enabled) return;
                            globalLoader.showLoader();
                            Script.validateLogin(emailInput.text, passwordInput.text)
                        }
                    }
                    Keys.onReturnPressed: {
                        if (enabled) signInButton.signInAction()
                    }
                    Keys.onEnterPressed: Keys.onReturnPressed()

                    function signInAction() {
                        if (!enabled) return;
                        globalLoader.showLoader();
                        Script.validateLogin(emailInput.text, passwordInput.text)
                    }
                }
            }
        }
    }
}
