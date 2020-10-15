class ErrorMessage {
    ErrorMessage({
        this.message = "",
        this.errCode = 0,
    });

    String message;
    int errCode;

    factory ErrorMessage.fromJson(Map<String, dynamic> json) => ErrorMessage(
        message: json["Message"] ?? "",
        errCode: json["ErrCode"] ?? 0,
    );
}
