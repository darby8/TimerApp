var auth = {
    accessToken: "",
    refreshToken: ""
};

function validateLogin(email, password) {
    globalLoader.showLoader();
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "https://backend-oversight.reak.co.in/api/login");
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                // mainWindow.loggedIn = true;
                try {
                    var response = JSON.parse(xhr.responseText);
                    mainWindow.loggedIn = true;
                    emailInput.text=""
                    passwordInput.text=""
                    appSettings.accessToken = response.payload.access_token;
                    tracker.setAccessToken(response.payload.access_token);
                    fetchUserProfile(response.payload.access_token)
                    tracker.fetchData(response.payload.access_token);
                    globalLoader.hideLoader();
                     mainWindow.loggedIn = true;
                       pageLoader.source = "../QML/pages/Time.qml"
                } catch (e) {
                    console.error("Failed to parse response:", e);
                     globalLoader.hideLoader()
                }
            } else {
                toast.show("Login failed, Please try again")
                console.error("Login failed:", xhr.status, xhr.responseText);
                 globalLoader.hideLoader()
            }
        }
    };
    var payload = {
        email: email,
        password: password
    };
    xhr.send(JSON.stringify(payload));
}


function logout(token){
    mainWindow.selectedTab = "Time"
    globalLoader.showLoader();
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "https://backend-oversight.reak.co.in/api/logout"); // API endpoint
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.setRequestHeader("ngrok-skip-browser-warning", "true");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200 || xhr.status === 204) {
                pageLoader.source = "./pages/Time.qml"
                mainWindow.loggedIn=false
                TimerManager.stop()
                 appSettings.accessToken = "";
                    // TimerManager.reset()
            } else {
                mainWindow.loggedIn = false;
                toast.show("Logout failed: Please try again")
                console.log("Error deleting:", xhr.status, xhr.responseText);
            }
        }
        globalLoader.hideLoader();

    };
    xhr.send();  // send DELETE request
}

function fetchUserProfile(token) {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://backend-oversight.reak.co.in/api/user/profile");  // replace with your API URL
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.setRequestHeader("ngrok-skip-browser-warning", "true");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                mainWindow.loggedIn = true;
                var response = JSON.parse(xhr.responseText);
                if (response.response === "success" && response.payload) {
                    var userId = response.payload.id;
                    var fullName = response.payload.name
                    var firstName = fullName.split(" ")[0];

                    TimerManager.setCurrentUser(String(userId));
                    TimerManager.loadSavedTime();

                    mainWindow.userName = firstName;
                    mainWindow.userEmail = response.payload.email;
                } else {
                    console.error("API returned failure:", response.message);
                }
            }else if (xhr.status === 401 || xhr.status === 403) {
                console.warn("Access token expired or invalid, redirecting to login.");
                toast.show("Session expired. Please log in again.");

                // Clear invalid token
                appSettings.accessToken = "";
                tracker.setAccessToken("");
                mainWindow.loggedIn = false;

                // Redirect to login
                pageLoader.source = "./pages/LoginPage.qml";
            } else {
                toast.show("Something error, Please try again.")
                mainWindow.loggedIn = false;
                console.error("Profile fetch failed with status:", xhr.status);
            }
        }
    }
    globalLoader.hideLoader();
    xhr.send();
}

function isValidGmail(email) {
    var gmailRegex = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
    return gmailRegex.test(email);
}

function getUserTimeLog(token, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://backend-oversight.reak.co.in/api/productivity");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("ngrok-skip-browser-warning", "true");

        xhr.onload = function() {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (callback) callback(data.payload.logs);
                } catch (e) {
                    console.error("JSON parse error:", e);
                    if (callback) callback([]);
                }
            } else {
                globalLoader.hideLoader();
                console.error("Request failed with status", xhr.status);
                toast.show("Error occured, Please try again.")
                mainWindow.loggedIn = false;
                if (callback) callback([]);
            }
             globalLoader.hideLoader();
        };

        xhr.onerror = function() {
            console.error("Network error");
            if (callback) callback([]);
        };

        xhr.send();
}


function formatMinutesToHoursMins(mins) {
    var hours = Math.floor(mins / 60)
    var minutes = mins % 60
    if (hours > 0 && minutes > 0)
        return hours + "h " + minutes + "m"
    else if (hours > 0)
        return hours + "h"
    else
        return minutes + "m"
}

function deleteProductivityById(accessToken, id, callback) {
    globalLoader.showLoader();
    var xhr = new XMLHttpRequest();
    var url = "https://backend-oversight.reak.co.in/api/productivity/" + encodeURIComponent(id);
    xhr.open("DELETE", url);    // DELETE method
    xhr.setRequestHeader("Authorization", "Bearer " + accessToken);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200 || xhr.status === 204) {
                console.log("Deleted successfully:", id);
                if (callback) callback(true);
            } else {
                toast.show("Error while deleting timeLog, Please try again.")
                mainWindow.loggedIn = false;
                console.error("Delete failed:", xhr.status, xhr.responseText);
            }
        }
        globalLoader.hideLoader();
    };
    xhr.send(); // DELETE call doesn't need a request body
}

function getUserAnalytics(token, callback){
    console.log(token,"=====================token============================")
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://backend-oversight.reak.co.in/api/analytics");
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.setRequestHeader("ngrok-skip-browser-warning", "true");

    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                if (callback) callback(data.payload.last30Days);
            } catch (e) {
                console.error("JSON parse error:", e);
                if (callback) callback([]);
            }
        } else {
            globalLoader.hideLoader();
            console.error("Request failed with status", xhr.status);
            toast.show("Error occured, Please try again.")
            mainWindow.loggedIn = false;
            if (callback) callback([]);
        }
         globalLoader.hideLoader();
    };

    xhr.onerror = function() {
        console.error("Network error");
        if (callback) callback([]);
    };
    xhr.send();
}

