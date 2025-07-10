// wgsd-client

import * as log from "log";
import { connect } from "ubus";

const bus = connect();

const wgst = bus.call(rpc_object, "status");
assert(wgst, "rpc error");

// TODO
