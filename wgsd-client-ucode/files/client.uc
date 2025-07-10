// wgsd-client

import * as log from "log";
import { connect } from "ubus";

const bus = connect();

const wgst = bus.call(rpc_object, "status");
assert(wgst, "rpc error");

const info = wgst[device];
assert(info, "device not found");

// TODO
