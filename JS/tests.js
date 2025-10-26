/**
 * @param {string} s
 * @param {number} numRows
 * @return {string}
 */
var convert = function (s, numRows) {
	if (numRows === 1) return s;

	res = "";
	for (let row = 0; row < numRows; row++) {
		const inc = 2 * (numRows - 1);
		for (let i = row; i < s.length; i += inc) {
			res += s[i];
			if (row > 0 && row < numRows - 1 && i + inc - 2 * row < s.length) {
				res += s[i + inc - 2 * row];
			}
		}
	}
	return res;
};

console.log(convert("PAYPALISHIRING", 3));
console.log(convert("PAYPALISHIRING", 4));
console.log(convert("A", 1));
