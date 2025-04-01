enum DialogName {
  empty(''),
  success('Success'), // Thành công
  failure('Failure'), // Thất bại
  confirm('Confirm'), // Xác nhận
  ;

  final String description;
  const DialogName(this.description);
  @override
  String toString() {
    return description;
  }
}