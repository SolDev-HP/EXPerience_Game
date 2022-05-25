// We need some way to log things out
// Setting this in initial stages will help 

import { Injectable } from "@angular/core";
@Injectable() 

export class LoggingService {
    log(message: any) {
        console.log(new Date() + " : " + JSON.stringify(message));
    }
}