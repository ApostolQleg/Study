/**
 * @param {string} s
 * @return {string}
 */

var longestPalindrome = function (s) {
	result = "";
	const length = s.length;

	function check(l, r) {
		while (l >= 0 && r < length && s[l] === s[r]) {
			l--;
			r++;
		}
		return s.slice(l + 1, r);
	}

	for (let i = 0; i < length; i++) {
		const check1 = check(i, i);
		check1.length > result.length ? (result = check1) : result;
		const check2 = check(i, i + 1);
		check2.length > result.length ? (result = check2) : result;
	}
	return result;
};

console.log(longestPalindrome("babadadadkdkdkdkdkkd"));
