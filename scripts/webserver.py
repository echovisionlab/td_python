# All General API-Webserver-Code should go here and never be touched again, unless the API-SPecification changes

import sys

sys.path.extend(["./scripts"])  # Without this, TD Python won't find the modules in the scripts folder
import touchdesigner


def onHTTPRequest(webServerDAT, request, response):
    handleRequest(request)
    response['statusCode'] = 200  # OK
    response['statusReason'] = 'OK'
    response['data'] = '<b>TouchDesigner: </b>' + webServerDAT.name
    return response


def handleRequest(request):
    if request["uri"] == "/v1/play":
        handlePlay(request)


def handlePlay(request):
    filepath = "PATH_TO_FILE"  # you will get these from the request
    layer = 2
    touchdesigner.play(filepath, layer)


def onWebSocketOpen(webServerDAT, client, uri):
    return


def onWebSocketClose(webServerDAT, client):
    return


def onWebSocketReceiveText(webServerDAT, client, data):
    webServerDAT.webSocketSendText(client, data)
    return


def onWebSocketReceiveBinary(webServerDAT, client, data):
    webServerDAT.webSocketSendBinary(client, data)
    return


def onWebSocketReceivePing(webServerDAT, client, data):
    webServerDAT.webSocketSendPong(client, data=data);
    return


def onWebSocketReceivePong(webServerDAT, client, data):
    return


def onServerStart(webServerDAT):
    return


def onServerStop(webServerDAT):
    return
