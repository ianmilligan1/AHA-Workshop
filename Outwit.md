# Outwit Hub Walkthrough

## The Setup
- Visit George Washington's wikipedia page (https://en.wikipedia.org/wiki/George_Washington)
- Imagine that we want to create a database of all the political parties that people have belonged to
- What we need to do is to train a computer to find a recurring field in data
- Now underneath this is the underlying HTML
- So we want to basically get it going
- Now this is just a *very basic* example – you could use this to scrape a diary for example, or many other things

## Hands-On Example
- Get users to open up Outwit Hub
- Click on 'scrapers'
- Click on 'new'
- Name it 'Presidential Parties'
- First line 'Name'
	+ Marker before: <th scope="row">Political party</th>
	+ Marker after:  - Wikipedia, the free encyclopedia</title>
- Second line 'Party'
	+ Marker before: <th scope="row">Political party</th>
	+ Marker after: </td>
- Then click 'Save'
- Then click 'Execute'

It should look like this:

![screenshot of complete Outwit Hub scraper](https://raw.githubusercontent.com/ianmilligan1/AHA-Workshop/master/Outwit-1.png)

Do this for the first five presidents. Are you happy with what you get?

## Try it with another category
- If you are not sure, why don't you try to grab "Born" and "Died"
- If you have an idea, try something funky
