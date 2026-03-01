class HnConstants {
  HnConstants._();

  static const firebaseBaseUrl = 'https://hacker-news.firebaseio.com/v0';
  static const webBaseUrl = 'https://news.ycombinator.com';
  static const algoliaBaseUrl = 'https://hn.algolia.com/api/v1';

  static const storiesPerPage = 20;

  static String itemUrl(int id) => '$webBaseUrl/item?id=$id';
  static String userUrl(String username) => '$webBaseUrl/user?id=$username';
}
