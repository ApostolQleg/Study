function ListNode(val, next) {
	this.val = val === undefined ? 0 : val;
	this.next = next === undefined ? null : next;
}

/**
 * @param {ListNode} l1
 * @param {ListNode} l2
 * @return {ListNode}
 */

var addTwoNumbers = function (l1, l2) {
	const dummy = new ListNode();
	let cur = dummy;
	let carry = 0;

	while (l1 || l2 || carry) {
		const v1 = l1 ? l1.val : 0;
		const v2 = l2 ? l2.val : 0;
		const val = v1 + v2 + carry;
		carry = Math.floor(val / 10);
		cur.next = new ListNode(val % 10);
		cur = cur.next;
		l1 = l1 ? l1.next : undefined;
		l2 = l2 ? l2.next : undefined;
	}
	return dummy.next;
};

const l1 = new ListNode(2, new ListNode(4, new ListNode(3)));
const l2 = new ListNode(5, new ListNode(6, new ListNode(4)));
const result = addTwoNumbers(l1, l2);
console.log(result.val + " -> " + result.next.val + " -> " + result.next.next.val); // Output: 7 -> 0 -> 8
