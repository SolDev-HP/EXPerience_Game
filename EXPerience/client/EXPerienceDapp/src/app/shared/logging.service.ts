// We need some way to log things out
// Setting this in initial stages will help 

import { Injectable } from "@angular/core";
import * as util from 'util';
import { inspect } from "util";

@Injectable() 
export class LoggingService {
    constructor() { }
    log(_logMsg: any) {
        console.log(new Date() + " : " + util.inspect(_logMsg));
    }
}