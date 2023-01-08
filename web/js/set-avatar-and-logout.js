// Paste this into your Console on the (`https://www.roblox.com/home`) website.
// This will set your torso to `Alder` and everything else to `Institutional White` and then logs you out.

$.ajax({method: "POST", url: "https://avatar.roblox.com/v2/avatar/set-wearing-assets", contentType: "application/json", data: JSON.stringify({"assets": []})}).then(data => console.log(data)).fail(error => console.log(error.responseText));
$.ajax({method: "POST", url: "https://avatar.roblox.com/v1/avatar/set-body-colors", contentType: "application/json", data: JSON.stringify({"headColorId": 1001, "torsoColorId": 1006, "rightArmColorId": 1001, "leftArmColorId": 1001, "rightLegColorId": 1001, "leftLegColorId":1001})}).then(data => console.log(data)).fail(error => console.log(error.responseText));
window.onbeforeunload = function(){
	return false;
};

$.ajax({method: "POST", url: "https://auth.roblox.com/v2/logout", contentType: "application/json"}).then(data => console.log(data)).fail(error => console.log(error.responseText));

// Now we try go back to the signup page.
location.href = "https://roblox.com/signup"