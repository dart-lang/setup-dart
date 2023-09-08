import { createRequire as __WEBPACK_EXTERNAL_createRequire } from "module";
/******/ var __webpack_modules__ = ({

/***/ 692:
/***/ ((module) => {

module.exports = eval("require")("@actions/core");


/***/ }),

/***/ 237:
/***/ ((module) => {

module.exports = eval("require")("@actions/exec");


/***/ }),

/***/ 736:
/***/ ((module) => {

module.exports = eval("require")("@actions/http-client");


/***/ }),

/***/ 207:
/***/ ((module) => {

module.exports = eval("require")("@actions/tool-cache");


/***/ }),

/***/ 147:
/***/ ((module) => {

module.exports = __WEBPACK_EXTERNAL_createRequire(import.meta.url)("fs");

/***/ }),

/***/ 188:
/***/ ((module) => {

module.exports = __WEBPACK_EXTERNAL_createRequire(import.meta.url)("module");

/***/ }),

/***/ 37:
/***/ ((module) => {

module.exports = __WEBPACK_EXTERNAL_createRequire(import.meta.url)("os");

/***/ }),

/***/ 282:
/***/ ((module) => {

module.exports = __WEBPACK_EXTERNAL_createRequire(import.meta.url)("process");

/***/ }),

/***/ 556:
/***/ ((__webpack_module__, __unused_webpack___webpack_exports__, __nccwpck_require__) => {

var _actions_core__WEBPACK_IMPORTED_MODULE_0___namespace_cache;
var _actions_exec__WEBPACK_IMPORTED_MODULE_1___namespace_cache;
var _actions_tool_cache__WEBPACK_IMPORTED_MODULE_3___namespace_cache;
var fs__WEBPACK_IMPORTED_MODULE_4___namespace_cache;
var os__WEBPACK_IMPORTED_MODULE_6___namespace_cache;
var process__WEBPACK_IMPORTED_MODULE_7___namespace_cache;
__nccwpck_require__.a(__webpack_module__, async (__webpack_handle_async_dependencies__, __webpack_async_result__) => { try {
/* harmony import */ var _actions_core__WEBPACK_IMPORTED_MODULE_0__ = __nccwpck_require__(692);
/* harmony import */ var _actions_exec__WEBPACK_IMPORTED_MODULE_1__ = __nccwpck_require__(237);
/* harmony import */ var _actions_http_client__WEBPACK_IMPORTED_MODULE_2__ = __nccwpck_require__(736);
/* harmony import */ var _actions_tool_cache__WEBPACK_IMPORTED_MODULE_3__ = __nccwpck_require__(207);
/* harmony import */ var fs__WEBPACK_IMPORTED_MODULE_4__ = __nccwpck_require__(147);
/* harmony import */ var module__WEBPACK_IMPORTED_MODULE_5__ = __nccwpck_require__(188);
/* harmony import */ var os__WEBPACK_IMPORTED_MODULE_6__ = __nccwpck_require__(37);
/* harmony import */ var process__WEBPACK_IMPORTED_MODULE_7__ = __nccwpck_require__(282);
// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.










const require = module__WEBPACK_IMPORTED_MODULE_5__.createRequire(import.meta.url);

// Setup properties for JS interop in Dart.

globalThis.self = globalThis;
globalThis.core = /*#__PURE__*/ (_actions_core__WEBPACK_IMPORTED_MODULE_0___namespace_cache || (_actions_core__WEBPACK_IMPORTED_MODULE_0___namespace_cache = __nccwpck_require__.t(_actions_core__WEBPACK_IMPORTED_MODULE_0__, 2)));
globalThis.exec = /*#__PURE__*/ (_actions_exec__WEBPACK_IMPORTED_MODULE_1___namespace_cache || (_actions_exec__WEBPACK_IMPORTED_MODULE_1___namespace_cache = __nccwpck_require__.t(_actions_exec__WEBPACK_IMPORTED_MODULE_1__, 2)));
globalThis.HttpClient = _actions_http_client__WEBPACK_IMPORTED_MODULE_2__.HttpClient;
globalThis.toolCache = /*#__PURE__*/ (_actions_tool_cache__WEBPACK_IMPORTED_MODULE_3___namespace_cache || (_actions_tool_cache__WEBPACK_IMPORTED_MODULE_3___namespace_cache = __nccwpck_require__.t(_actions_tool_cache__WEBPACK_IMPORTED_MODULE_3__, 2)));
globalThis.fs = /*#__PURE__*/ (fs__WEBPACK_IMPORTED_MODULE_4___namespace_cache || (fs__WEBPACK_IMPORTED_MODULE_4___namespace_cache = __nccwpck_require__.t(fs__WEBPACK_IMPORTED_MODULE_4__, 2)));
globalThis.os = /*#__PURE__*/ (os__WEBPACK_IMPORTED_MODULE_6___namespace_cache || (os__WEBPACK_IMPORTED_MODULE_6___namespace_cache = __nccwpck_require__.t(os__WEBPACK_IMPORTED_MODULE_6__, 2)));
globalThis.process = /*#__PURE__*/ (process__WEBPACK_IMPORTED_MODULE_7___namespace_cache || (process__WEBPACK_IMPORTED_MODULE_7___namespace_cache = __nccwpck_require__.t(process__WEBPACK_IMPORTED_MODULE_7__, 2)));
globalThis.location = { href: `file://${process__WEBPACK_IMPORTED_MODULE_7__.cwd()}/`}

globalThis.dartMainRunner = async function(main, args) {
  const dir = process__WEBPACK_IMPORTED_MODULE_7__.argv[2];
  await main(dir);
}

async function scriptMain() {
  // We have to load `main.js` here so that the `dartMainRunner` hook is
  // registered before the IIFE in `dart_main.js` runs.
  require('../dist/main.cjs');
}

if (require.main === require.module) {
  await scriptMain();
}

__webpack_async_result__();
} catch(e) { __webpack_async_result__(e); } }, 1);

/***/ })

/******/ });
/************************************************************************/
/******/ // The module cache
/******/ var __webpack_module_cache__ = {};
/******/ 
/******/ // The require function
/******/ function __nccwpck_require__(moduleId) {
/******/ 	// Check if module is in cache
/******/ 	var cachedModule = __webpack_module_cache__[moduleId];
/******/ 	if (cachedModule !== undefined) {
/******/ 		return cachedModule.exports;
/******/ 	}
/******/ 	// Create a new module (and put it into the cache)
/******/ 	var module = __webpack_module_cache__[moduleId] = {
/******/ 		// no module.id needed
/******/ 		// no module.loaded needed
/******/ 		exports: {}
/******/ 	};
/******/ 
/******/ 	// Execute the module function
/******/ 	var threw = true;
/******/ 	try {
/******/ 		__webpack_modules__[moduleId](module, module.exports, __nccwpck_require__);
/******/ 		threw = false;
/******/ 	} finally {
/******/ 		if(threw) delete __webpack_module_cache__[moduleId];
/******/ 	}
/******/ 
/******/ 	// Return the exports of the module
/******/ 	return module.exports;
/******/ }
/******/ 
/************************************************************************/
/******/ /* webpack/runtime/async module */
/******/ (() => {
/******/ 	var webpackQueues = typeof Symbol === "function" ? Symbol("webpack queues") : "__webpack_queues__";
/******/ 	var webpackExports = typeof Symbol === "function" ? Symbol("webpack exports") : "__webpack_exports__";
/******/ 	var webpackError = typeof Symbol === "function" ? Symbol("webpack error") : "__webpack_error__";
/******/ 	var resolveQueue = (queue) => {
/******/ 		if(queue && !queue.d) {
/******/ 			queue.d = 1;
/******/ 			queue.forEach((fn) => (fn.r--));
/******/ 			queue.forEach((fn) => (fn.r-- ? fn.r++ : fn()));
/******/ 		}
/******/ 	}
/******/ 	var wrapDeps = (deps) => (deps.map((dep) => {
/******/ 		if(dep !== null && typeof dep === "object") {
/******/ 			if(dep[webpackQueues]) return dep;
/******/ 			if(dep.then) {
/******/ 				var queue = [];
/******/ 				queue.d = 0;
/******/ 				dep.then((r) => {
/******/ 					obj[webpackExports] = r;
/******/ 					resolveQueue(queue);
/******/ 				}, (e) => {
/******/ 					obj[webpackError] = e;
/******/ 					resolveQueue(queue);
/******/ 				});
/******/ 				var obj = {};
/******/ 				obj[webpackQueues] = (fn) => (fn(queue));
/******/ 				return obj;
/******/ 			}
/******/ 		}
/******/ 		var ret = {};
/******/ 		ret[webpackQueues] = x => {};
/******/ 		ret[webpackExports] = dep;
/******/ 		return ret;
/******/ 	}));
/******/ 	__nccwpck_require__.a = (module, body, hasAwait) => {
/******/ 		var queue;
/******/ 		hasAwait && ((queue = []).d = 1);
/******/ 		var depQueues = new Set();
/******/ 		var exports = module.exports;
/******/ 		var currentDeps;
/******/ 		var outerResolve;
/******/ 		var reject;
/******/ 		var promise = new Promise((resolve, rej) => {
/******/ 			reject = rej;
/******/ 			outerResolve = resolve;
/******/ 		});
/******/ 		promise[webpackExports] = exports;
/******/ 		promise[webpackQueues] = (fn) => (queue && fn(queue), depQueues.forEach(fn), promise["catch"](x => {}));
/******/ 		module.exports = promise;
/******/ 		body((deps) => {
/******/ 			currentDeps = wrapDeps(deps);
/******/ 			var fn;
/******/ 			var getResult = () => (currentDeps.map((d) => {
/******/ 				if(d[webpackError]) throw d[webpackError];
/******/ 				return d[webpackExports];
/******/ 			}))
/******/ 			var promise = new Promise((resolve) => {
/******/ 				fn = () => (resolve(getResult));
/******/ 				fn.r = 0;
/******/ 				var fnQueue = (q) => (q !== queue && !depQueues.has(q) && (depQueues.add(q), q && !q.d && (fn.r++, q.push(fn))));
/******/ 				currentDeps.map((dep) => (dep[webpackQueues](fnQueue)));
/******/ 			});
/******/ 			return fn.r ? promise : getResult();
/******/ 		}, (err) => ((err ? reject(promise[webpackError] = err) : outerResolve(exports)), resolveQueue(queue)));
/******/ 		queue && (queue.d = 0);
/******/ 	};
/******/ })();
/******/ 
/******/ /* webpack/runtime/create fake namespace object */
/******/ (() => {
/******/ 	var getProto = Object.getPrototypeOf ? (obj) => (Object.getPrototypeOf(obj)) : (obj) => (obj.__proto__);
/******/ 	var leafPrototypes;
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 16: return value when it's Promise-like
/******/ 	// mode & 8|1: behave like require
/******/ 	__nccwpck_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = this(value);
/******/ 		if(mode & 8) return value;
/******/ 		if(typeof value === 'object' && value) {
/******/ 			if((mode & 4) && value.__esModule) return value;
/******/ 			if((mode & 16) && typeof value.then === 'function') return value;
/******/ 		}
/******/ 		var ns = Object.create(null);
/******/ 		__nccwpck_require__.r(ns);
/******/ 		var def = {};
/******/ 		leafPrototypes = leafPrototypes || [null, getProto({}), getProto([]), getProto(getProto)];
/******/ 		for(var current = mode & 2 && value; typeof current == 'object' && !~leafPrototypes.indexOf(current); current = getProto(current)) {
/******/ 			Object.getOwnPropertyNames(current).forEach((key) => (def[key] = () => (value[key])));
/******/ 		}
/******/ 		def['default'] = () => (value);
/******/ 		__nccwpck_require__.d(ns, def);
/******/ 		return ns;
/******/ 	};
/******/ })();
/******/ 
/******/ /* webpack/runtime/define property getters */
/******/ (() => {
/******/ 	// define getter functions for harmony exports
/******/ 	__nccwpck_require__.d = (exports, definition) => {
/******/ 		for(var key in definition) {
/******/ 			if(__nccwpck_require__.o(definition, key) && !__nccwpck_require__.o(exports, key)) {
/******/ 				Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 			}
/******/ 		}
/******/ 	};
/******/ })();
/******/ 
/******/ /* webpack/runtime/hasOwnProperty shorthand */
/******/ (() => {
/******/ 	__nccwpck_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ })();
/******/ 
/******/ /* webpack/runtime/make namespace object */
/******/ (() => {
/******/ 	// define __esModule on exports
/******/ 	__nccwpck_require__.r = (exports) => {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/ })();
/******/ 
/******/ /* webpack/runtime/compat */
/******/ 
/******/ if (typeof __nccwpck_require__ !== 'undefined') __nccwpck_require__.ab = new URL('.', import.meta.url).pathname.slice(import.meta.url.match(/^file:\/\/\/\w:/) ? 1 : 0, -1) + "/";
/******/ 
/************************************************************************/
/******/ 
/******/ // startup
/******/ // Load entry module and return exports
/******/ // This entry module used 'module' so it can't be inlined
/******/ var __webpack_exports__ = __nccwpck_require__(556);
/******/ __webpack_exports__ = await __webpack_exports__;
/******/ 
