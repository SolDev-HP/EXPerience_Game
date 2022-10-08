import traceback

def logExceptionMakeReadable(err: BaseException):
    print( "EXCEPTION FORMAT PRINT: {}: {}".format( type(err).__name__, err ) )
    print( "EXCEPTION TRACE  PRINT:\n{}".format( "".join(traceback.format_exception(type(err), err, err.__traceback__)) ))
