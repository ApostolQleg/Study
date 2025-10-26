/**
 * @param {number[]} nums1
 * @param {number[]} nums2
 * @return {number}
 */
var findMedianSortedArrays = function (nums1, nums2) {
	const nums = nums1.concat(nums2).toSorted((a, b) => a - b);
	console.log(nums);
	const length = nums.length;
	let avg = 0.0;
	if (length % 2 === 0) {
		avg = (nums[length / 2] + nums[length / 2 - 1]) / 2;
	} else {
		console.log(Math.floor(length / 2));
		avg = nums[Math.floor(length / 2)];
	}
	return avg;
};

console.log(findMedianSortedArrays([1, 2, 3, 4, 5], [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]));
