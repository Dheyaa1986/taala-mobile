import 'package:equatable/equatable.dart';

class CustomException extends Equatable implements Exception {
  final String message;
  final int? code;

  const CustomException(this.message,{ this.code});

  @override
  String toString() {
    return message;
  }
  
  @override
  List<Object?> get props => [message];
}

class FetchDataException extends CustomException {
  const FetchDataException([message]) : super(message??"Error During Communication");
}

class BadRequestException extends CustomException {
  const BadRequestException([message]) : super(message??"Bad Request");
}
class NoVerifiedException extends CustomException {
  const NoVerifiedException([message]) : super(message??"Bad Request");
}

class UnauthorizedException extends CustomException {
  const UnauthorizedException([message]) : super(message??"Unauthorized");
}

class NotFoundException extends CustomException {
  const NotFoundException([message]) : super(message??"Requested Info Not Found");
}

class ConflictException extends CustomException {
  const ConflictException([message]) : super(message??"Conflict Occurred");
}

class InternalServerErrorException extends CustomException {
  const InternalServerErrorException([message])
      : super(message??"Internal Server Error");
}

class NoInternetConnectionException extends CustomException {
  const NoInternetConnectionException([message])
      : super(message??"No Internet Connection");
}

class CacheException implements Exception {}
