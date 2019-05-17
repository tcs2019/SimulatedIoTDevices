class ServerAPI {
  String news_id;
  String news_display;
  String news_tittle;
  String news_author;
  String news_link;



  ServerAPI (
      {this.news_id,
      this.news_display,
      this.news_tittle,
      this.news_author,
      this.news_link});
      


  factory ServerAPI.fromJson(Map json) {
    return new ServerAPI(
      news_id: json['news_id'],
      news_display: json['news_display'],
      news_tittle: json['news_tittle'],
      news_author: json['news_author'],
      news_link: json['news_link'],
    );
  }
}