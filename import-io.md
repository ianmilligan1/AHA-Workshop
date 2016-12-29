# Import.io Lesson

## The Problem
Let's imagine that we want to scrape two things: a database of all Top-40 Songs, and a database of all home children that came to Canada. They're held in relatively common formats: one a basic webpage with lots of links, and the other a more structured table found in Canada's national library and archives.

**Top 40 Lyrics**: [http://www.top40db.net/Find/Songs.asp?By=Year&ID=1970](http://www.top40db.net/Find/Songs.asp?By=Year&ID=1970)
**Home Children**: [http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/list.aspx?](http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/list.aspx?)

How would we grab all this material so we can work with it? A few different options:
- we could write a Python program to grab this material, perhaps inspired by the *Programming Historian*;
- we could manually copy and paste it all page-by-page, which would give us carpal tunnel syndrome;
- we could turn to a service to help us gather this information.

Let's turn to the service, which in turn lets us begin to think about the underlying structures of web scraping.

## Import.io
Import.io is a good starting point for this. A start-up company, this lets you scrape the web, and you can even subsequently create an API for other people to work with it - i.e. you could create an API to help people work with the home children records.

More importantly, for us, you can quickly turn this data into a CSV file that you could explore in a spreadsheet.

## Case Study One: The Song Lyrics
Let's take a look at the song lyric website again: <http://www.top40db.net/Find/Songs.asp?By=Year&ID=1970>

Let's try changing the URL, so we see the songs from 1971: <http://www.top40db.net/Find/Songs.asp?By=Year&ID=1971>

And then from 1972: <http://www.top40db.net/Find/Songs.asp?By=Year&ID=1972>

Let's experiment to find the earliest (turns out to be 1955 by trial and error): <http://www.top40db.net/Find/Songs.asp?By=Year&ID=1955>

And the latest (turns out to be 2014 by trial and error): <http://www.top40db.net/Find/Songs.asp?By=Year&ID=2014>

So to be able to grab this material, we would want to make a little database that took the lyric URL and did the following:

http://www.top40db.net/Find/Songs.asp?By=Year&ID=X, where `X` is a value between 1955 and 2014. We'd want a scraper to grab this material, and save it for us. 

### Let's try
The first starting point should be 

1. Visit the Import.io dashboard [here](http://dash.import.io)
2. Create an account
3. Get to the dashboard and click "New Extractor"
4. Paste in <http://www.top40db.net/Find/Songs.asp?By=Year&ID=1970>
5. Note that it begins processing the page in the background
6. Once the table appears, note that it actually read the material properly - take a quick look around!
7. Some of the columns aren't that useful - let's delete Imgtag image column and the Song Artist one, and rename the columns to "Title" and "Artist"
8. Let's actually say we are done

We now have it set up for one page - if we were to click "Run URLs" we would get the data from 1970. But we want it for 1955 to 2014. How do we do that?

1. Click on "Show URL Generator"
2. Highlight "1970" - remember that's our X variable
3. And then set up a range of numbers from 1955 to 2014, with a step of 1
4. Click "Remove all URLs"
5. Click "add to list"
6. Click "save"
7. Click "Run URLs" - this will cost 60 of our free 500 credits per month

It will take about two or three minutes. You should have a dataset of 23,168 songs. Click the "eye" to get a hint of what it looks like, and then download the CSV.

Hurray! Let's try something a bit more involved.

## Case Study Two: Library and Archives Canada

Let's look at the page itself: <http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/search.aspx>

To get a sense of some information, just click "Search" to see all results.

Let's click "Next" note the URL changes: <http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/list.aspx?p_ID=30>

And when you click next, note it changes one more time: <http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/list.aspx?p_ID=60>

And we can actually go to the end - LAC limits responses to 2000 hits, so this is the last one: <http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/list.aspx?p_ID=1995>

Let's go back to the search and just do a search for 1969 in Year of Arrival: <http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/search.aspx>. Note it says 473 records... so what would the last URL be?

The first is <http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/list.aspx?ArrivalYear=1869&> and the last page is <http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/list.aspx?ArrivalYear=1869&p_ID=450>. 

So we want to do similar to before, but steps of 30 between 1 and 450.

### Let's Try

#### Setting up the Extractor
1. Return to the dashboard: <https://dash.import.io/>
2. Click on "New Extractor"
3. Let's paste the last URL here: <http://www.bac-lac.gc.ca/eng/discover/immigration/immigration-records/home-children-1869-1930/immigration-records/Pages/list.aspx?ArrivalYear=1869&p_ID=450>
4. Note that the default columns bear NO resemblance to the data we want to scrape - so we will have to set it up ourselves...
5. Click "Clear table" and let's dig in.
6. Now we have to imagine what we might want our table to look like.. in this case, we want it to look like hwat Library and Archives Canada has!
7. So first column will be Surname. Let's rename it "Surname"
8. Select "Stoddard." It finds one. Now click the next one "STODDART". It has now guessed we want all the data!
9. Click "Add column" and do the same for all other data.
10. When done, click "Done"

#### Setting up the URLs
1. Same as before, but highlight "450" and make it a range from 0 to 450, with steps of 30. This will take 16 URLs.
2. Clic "Remove all URls"
3. Click "add to list"
4. Click "save"
5. Click "Run URLs"
6. Wait and then profit

