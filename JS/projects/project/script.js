const startButton = document.getElementById("startButton");
const player = document.getElementById("player");
player.style.display = "none";

startButton.addEventListener("click", () => {
	startButton.style.display = "none";
	player.style.display = "block";
});
