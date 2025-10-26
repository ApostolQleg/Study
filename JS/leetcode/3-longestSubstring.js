/**
 * @param {string} s
 * @return {number}
 */
var lengthOfLongestSubstring = function (s) {
	let seen = {};
	let left = 0;
	let max = 0;
	const length = s.length;
	for (let right = 0; right < length; right++) {
		const char = s[right];
		if (char in seen && seen[char] >= left) {
			left = seen[char] + 1;
		} else {
			max < right - left + 1 ? (max = right - left + 1) : max;
		}
		seen[char] = right;
	}
	return max;
};

console.log(lengthOfLongestSubstring("abcabcbb"));
console.log(lengthOfLongestSubstring("bbbbbb"));
console.log(lengthOfLongestSubstring("abcdcefg"));
