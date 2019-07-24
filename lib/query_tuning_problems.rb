# == Schema Information
#
# Table name: cats
#
#  id          :integer      not null, primary key
#  name        :string
#  color       :string
#  breed       :string
#
# Table name: toys
#
#  id          :integer      not null, primary key
#  name        :string
#  color       :string
#  price       :integer
#
# Table name: cattoys
#
#  id          :integer      not null, primary key
#  cat_id      :integer      not null, foriegn key
#  toy_id      :integer      not null, foreign key

require_relative '../data/query_tuning_setup.rb'

# Run the specs and make sure to make the query plans for the following 
# questions as efficient as possible.

# Experiment with adding and dropping indexes, and using subqueries vs. other 
# methods to see which are more efficient.

def example_find_jet
# Find the breed and color for the cat named 'Jet'.

# Get cost within the range of: 4..15

#  CREATE INDEX cats_name ON cats(name)

execute(<<-SQL)
  SELECT
    cats.name
  FROM
    cats
  WHERE 
    cats.name = 'Jet'
  SQL
end
# CREATE INDEX cats_id ON cats(id)
# CREATE INDEX cats_name ON cats(name)
# CREATE INDEX toys_id ON toys(id)


def cats_and_toys_alike
  # Find all the cat names where the cat and the toy they own are both the color 'Blue'.

  # Order alphabetically by cat name
  # Get your overall cost lower than: 590
  execute(<<-SQL)
    SELECT DISTINCT cats.name 
    FROM cats
    JOIN cattoys on cattoys.cat_id = cats.id
    JOIN toys on toys.id = cattoys.toy_id
    where cats.color = 'Blue' and toys.color = 'Blue'
    ORDER BY cats.name
  SQL
end

def toyless_blue_cats
  # Use a type of JOIN that will list the names of all the cats that are 'Navy Blue' and have no toys. 

  # Get your overall cost lower than: 95
  execute(<<-SQL)
    SELECT cats.name 
    from cats
    LEFT JOIN cattoys on cattoys.cat_id = cats.id 
    WHERE cats.color = 'Navy Blue' 
    AND cattoys.toy_id IS NULL 
  SQL
end

def find_unknown
  # Find all the toys names that belong to the cat who's breed is 'Unknown'.

  # Order alphabetically by toy name

  # Get your overall cost lower than: 406
  execute(<<-SQL)
  SELECT toys.name
  from toys 
  join cattoys on cattoys.toy_id = toys.id
  join cats on cats.id = cattoys.cat_id
  where cats.breed = 'Unknown'
  ORDER BY toys.name ASC
  SQL
end

def cats_like_johnson
  # Find the breed of the 'Lavender' colored cat named 'Johnson'. 
  # Then find all the name of the other cats that belong to that breed. 
  # Include the original Lavendar colored cat name Johnson in your results.

  # Order alphabetically by cat name

  # Get your overall cost lower than: 100
  execute(<<-SQL)
    SELECT cats.name
    from cats 
    JOIN cats as c1 on c1.breed = cats.breed
    where c1.name = 'Johnson' and c1.color = 'Lavender'
    ORDER BY cats.name ASC
  SQL
end


def cheap_toys_and_their_cats
  # Find the cheapest toy. Then list the name of all the cats that own that toy.

  # Order alphabetically by cats name
  # Get your overall cost lower than: 230
  execute(<<-SQL)
    SELECT cats.name 
    FROM cats 
    JOIN cattoys on cattoys.cat_id = cats.id
    Join toys on cattoys.toy_id = toys.id
    where toys.price = (select min(toys.price) from toys )
    ORDER BY cats.name ASC
  
  SQL
end

def cats_with_a_lot
  # Find the names of all cats with more than 7 toys.
  
  # Order alphabetically by cat name
  # Get your overall cost lower than: 1200
  execute(<<-SQL)
    SELECT cats.name
    FROM cats where cats.id in
    (SELECT cattoys.cat_id 
      FROM cats
      JOIN cattoys on cattoys.cat_id = cats.id
      GROUP BY cattoys.cat_id 
      HAVING COUNT(cattoys.toy_id) > 7 
    )
    ORDER BY cats.name ASC
  SQL
end


def expensive_tastes
  # Find the most expensive toy then list the toys's name, toy's color, and the name of each cat that owns that toy.

  # Order alphabetically by cat name
  # Get your overall cost lower than: 720
  execute(<<-SQL)
    SELECT cats.name, toys.name, toys.color 
    FROM toys JOIN cattoys ON cattoys.toy_id = toys.id
    JOIN cats ON cattoys.cat_id = cats.id
    where toys.price = (SELECT MAX(price) from toys)
    ORDER by cats.name ASC
  SQL
end


def five_cheap_toys
  # Find the name and prices for the five cheapest toys.

  # Order alphabetically by toy name.
  # Get your overall cost lower than: 425
  execute(<<-SQL)
  SELECT toys.name, toys.price 
  FROM toys 
  where toys.price IN 
  (select toys.price 
  from toys 
  order by price ASC 
  LIMIT 5)
  ORDER BY toys.name ASC
  LIMIT 5
  
  SQL
end

def top_cat
  # Finds the name of the single cat who has the most toys and the number of toys.

  # Get your overall cost lower than: 1050
  execute(<<-SQL)
  SELECT cats.name, count(*)
  FROM cats 
  JOIN cattoys ON cattoys.cat_id = cats.id
  WHERE cats.id = 
  (select CAT.cat_id
    FROM
  ( SELECT COUNT(cat_id), cat_id  from cattoys GROUP BY cat_id ORDER BY COUNT(cat_id) DESC  limit 1 ) AS CAT)
  
  group by cats.name
  SQL
end


  # SELECT cats.name FROM cats
  # JOIN cattoys ON cattoys.cat_id = cats.id
  # JOIN toys ON toys.id = cattoys.toy_id
  # GROUP BY cats.name
  # HAVING COUNT(cattoys.toy_id) = (select MAX(cat_id) from cattoys)

