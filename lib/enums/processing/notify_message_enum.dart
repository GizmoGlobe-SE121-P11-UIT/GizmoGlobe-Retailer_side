enum NotifyMessage {
  empty(''),
  msg1('Signed in successfully.'), // Đăng nhập thành công
  msg2('Failed to sign in. Please try again.'), // Đăng nhập thất bại. Vui lòng thử lại
  msg3('Failed to send verification link. Please try again.'), // Gửi liên kết xác minh thất bại. Vui lòng thử lại
  msg4('Error changing password. Please try again.'), // Lỗi thay đổi mật khẩu. Vui lòng thử lại
  msg5('Passwords do not match.'), // Mật khẩu không khớp
  msg6('A verification email has been sent to your email address. Please verify your email to complete signing up.'), // Một email xác minh đã được gửi đến địa chỉ email của bạn. Vui lòng xác minh email của bạn để hoàn tất việc đăng ký
  msg7('Failed to sign up. Please try again.'), // Đăng ký thất bại. Vui lòng thử lại
  msg8('A verification link has been sent to your email address. Please verify your email to reset your password.'), // Một liên kết xác minh đã được gửi đến địa chỉ email của bạn. Vui lòng xác minh email của bạn để đặt lại mật khẩu\
  msg9('Failed to sign out. Please try again.'), // Đăng xuất thất bại. Vui lòng thử lại
  msg10('Email not verified. Please verify your email.'), // Email chưa được xác minh. Vui lòng xác minh email của bạn
  msg11('Invalid email or password'), // Email hoặc mật khẩu không hợp lệ
  msg12('This email is not registered in the system'), // Email này không được đăng ký trong hệ thống
  msg13('Product added successfully.'), // Sản phẩm đã được thêm thành công
  msg14('Failed to add product. Please try again.'), // Không thể thêm sản phẩm. Vui lòng thử lại
  msg15('Product updated successfully.'), // Sản phẩm đã được cập nhật thành công
  msg16('Failed to update product. Please try again.'), // Không thể cập nhật sản phẩm. Vui lòng thử lại
  error('An unexpected error occurred. Please try again.'), // Đã xảy ra lỗi không mong muốn. Vui lòng thử lại
  ;

  final String message;
  const NotifyMessage(this.message);

  @override
  String toString() => message;
}