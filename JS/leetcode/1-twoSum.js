/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
var twoSum = function (nums, target) {
	let seen = {};
	for (let el = 0; el < nums.length; el++) {
		if (target - nums[el] in seen) {
			return [seen[target - nums[el]], el];
		} else {
			seen[nums[el]] = el;
		}
	}
};

console.dir(twoSum([2, 7, 11, 15], 9));
console.dir(twoSum([3, 2, 4], 6));
console.dir(twoSum([3, 3], 6));
