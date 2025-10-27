const startButton = document.getElementById("startButton");
const player = document.getElementById("player");
player.style.display = "none";

startButton.addEventListener("click", () => {
	startButton.style.display = "none";
	player.style.top = "50%";
	player.style.left = "50%";
	player.style.display = "block";
});

// Movement logic (WASD) for the player (will be changed a lot)
const keysPressed = {};
const step = 10;
let x = window.innerWidth / 2; // Centered x position
let y = window.innerHeight / 2; // Centered y position

document.addEventListener("keydown", (event) => {
	keysPressed[event.code] = true;
});

document.addEventListener("keyup", (event) => {
	keysPressed[event.code] = false;
});

function movement() {
	if (keysPressed["KeyW"]) {
		y += step;
	}
	if (keysPressed["KeyA"]) {
		x += step;
	}
	if (keysPressed["KeyS"]) {
		y -= step;
	}
	if (keysPressed["KeyD"]) {
		x -= step;
	}

	background.style.top = y + "px";
	background.style.left = x + "px";

	if (x > window.innerWidth) {
		x = 0;
	}
	if (x < 0) {
		x = window.innerWidth;
	}
	if (y > window.innerHeight) {
		y = 0;
	}
	if (y < 0) {
		y = window.innerHeight;
	}

	requestAnimationFrame(movement);
}

requestAnimationFrame(movement);
