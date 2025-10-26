// Factory function
function createCircle(radius) {
	return {
		radius,
		draw: function () {
			console.log("circle with the radius of " + radius);
		},
	};
}
const circle = createCircle(1);

// Constructor function
function Circle(radius) {
	this.radius = radius;
	this.draw = function () {
		console.log("circle with the radius of " + radius);
	};
}
const another = new Circle(3);


