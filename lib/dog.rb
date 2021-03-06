class Dog

    attr_accessor :id, :name, :breed

    def initialize( id: nil, name:, breed: )
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        );
        SQL
        DB[ :conn ].execute( sql )    
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs;"
        DB[ :conn ].execute( sql )
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
              INSERT INTO dogs (name, breed)
              VALUES (?, ?)
            SQL
            DB[ :conn ].execute( sql, self.name, self.breed )
            @id = DB[ :conn ].execute( "SELECT last_insert_rowid() FROM dogs" )[ 0 ][ 0 ]
        end
        self
    end

    def self.create( attributes )
        new_dog = Dog.new( attributes )
        new_dog.save
    end

    def self.new_from_db( attributes )
        new_dog = Dog.new( id: attributes[ 0 ], name: attributes[ 1 ], breed: attributes[ 2 ] )
    end

    def self.find_by_id( id )
        sql = "SELECT * FROM dogs WHERE id = ?;"
        attributes = DB[ :conn ].execute( sql, id ).first
        Dog.new( id: attributes[ 0 ], name: attributes[ 1 ], breed: attributes[ 2 ] )
    end

    def self.find_or_create_by( name:, breed: )
        sql = <<-SQL
              SELECT *FROM dogs
              WHERE name = ?
              AND breed = ?
              LIMIT 1
            SQL
        row = DB[ :conn ].execute( sql,name,breed )
        if !row.empty?
          dog = Dog.new(id: row[ 0 ][ 0 ], name: row[ 0 ][ 1 ], breed: row[ 0 ][ 2 ])
        else
          dog = self.create( name: name, breed: breed )
        end
        dog
    end

    def self.find_by_name( name )
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1;"
        attributes = DB[ :conn ].execute( sql, name ).first
        self.new_from_db( attributes )
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[ :conn ].execute( sql, self.name, self.breed, self.id )
    end

end
