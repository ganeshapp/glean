I want to build a flutter android app that can help me keep track of intersting things I find on the internet, especially hackernews and give me the ability to consolidate them all in one place per week. 

Considering it is mostly hacker news (articles, comments/comment threads, etc.) and a few from other sources (like a bunch of text selected from some website or a tweet from the X app), I am thinking I should build a hackernews client app with some additional features. 

In hackernews client app, I really love Hews (it is an android app that is allows for reading hacker news in a clean and minimalistic way, but also information dense without looking ugly and cluttered).

hews allows for bookmarking the hackernews submissions (basically the submission link with the comments etc.). But I want to be able to bookmark some interesting comments also. 

Also while bookmarking the submissions, there are two parts: 
1. The submitted article link
2. The hackernews submission link which has the discussions for that submission.

When I bookmark a submission, I want to be able to add an optional summary for that submission. 

I also want the ability to bookmark any comment. In that case it should just be the comment text and the comment link. 

On other apps like Twitter or Website etc. I want the ability to send the twitter link or the selected text on the website to the app and have it bookmarked with the text/tweet and the link to the website/tweet. 

The bookmark page should be sorted in LIFO. So basically the most recent bookmarks should be at the top. 

All other features of Hews should be included in the app. Ability to login, ability to comment, ability to see different genres like Show HN, Ask HN etc. Ability to search and all that. 


The settings page should also allow me to add a github PAT token to the app and add a repo and a folder in the repo to store the weekly bookmarks in a markdown file. 

When I go to the github publish page, all the bookmarks that have not been published yet should be gathered. 

1. For the articles it should have the link to the article, the optional summary that I have added, the hackernews submission link. 
2. For the comments bookmarked, it should put the comment in quote, the username of the comment and the username should be linked to the comment link. 
3. For tweet, it should show the tweet text, the username of the tweet and the username should be linked to the tweet link. 
4. For website, it should show the selected text and the link to the website with the website title. 

The markdown file title should be the week number of the date when I publish the bookmarks that are not yet published. Something like "Week-12.md" or "Week-13.md".

All the bookmarks should be stored in a local database. When I go to the github publish page, the app should gather all the bookmarks that have not been published yet and then publish them to the github repo.

Design:
I am interested in just dark mode. The color scheme should be minimalistic and clean. 