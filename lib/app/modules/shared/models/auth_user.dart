class AuthUserModel{
  String? id;
  String? email;
  bool? asVerified;
  String? username;

  AuthUserModel(this.id, this.email, this.asVerified, this.username);

  String? getId(){
    return this.id;
  }

  String? getEmail(){
    return this.email;
  }

  String? getUsername(){
    return this.username;
  }

  bool? getAsVerified(){
    return this.asVerified;
  }

  void setId(String value){
    this.id = value;
  }

  void setEmail(String value){
    this.email = value;
  }

  void setUsername(String value){
    this.username = value;
  }

  void setAsVerified(bool value){
    this.asVerified = value;
  }

}