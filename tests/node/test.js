#!/usr/bin/env node

/*
 *	MetaCall Distributable by Parra Studios
 *	Distributable infrastructure for MetaCall.
 *
 *	Copyright (C) 2016 - 2025 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
 *
 *	Licensed under the Apache License, Version 2.0 (the "License");
 *	you may not use this file except in compliance with the License.
 *	You may obtain a copy of the License at
 *
 *		http://www.apache.org/licenses/LICENSE-2.0
 *
 *	Unless required by applicable law or agreed to in writing, software
 *	distributed under the License is distributed on an "AS IS" BASIS,
 *	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *	See the License for the specific language governing permissions and
 *	limitations under the License.
 *
 */

const assert = require('node:assert');
const { metacall, metacall_load_from_file, metacall_inspect } = require('metacall');

// Test Monkey Patch
const { three_str } = require('test.mock');

// Test NPM
const is_number = require('is-number');

assert(is_number(3), true);

module.exports = {
	mock: function() {
		/* Mock */
		console.log(three_str);
		console.log(three_str('a', 'b', 'c'));
	},
	python: function() {
		/* Python */
		console.log(metacall_load_from_file('py', [ 'sum.py' ]));
		console.log(metacall_inspect());
		console.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
		console.log(metacall('sum', 111111, 222222, 33334));
		console.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
	},
};
