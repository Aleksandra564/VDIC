class point_c;
	real x;
	real y;
	
	function new(real x_r, real y_r);
		x = x_r;
		y = y_r;
	endfunction
	
	function string to_string();	// converts x and y coordinates into string
		string point_str;
		point_str = $sformatf("(%0.2f, %0.2f)", x, y);
		return point_str;
	endfunction
	
endclass : point_c


virtual class shape_c;
	string name;
	protected point_c points[$];
	
	function new(string name_s, point_c points_p[$]);
		name = name_s;
		points = points_p;
	endfunction
	
	pure virtual function real get_area();
	
	function void print();
		$display("------------------------------");
		$display("This is: %0s ", name);
		foreach (points[i]) begin
			$display("%0s", points[i].to_string());
		end
	endfunction : print
	
endclass : shape_c


///////////////////////////////////////////////////////////
//	SHAPES
///////////////////////////////////////////////////////////
class polygon_c extends shape_c;
	
	function new(string name, point_c points[$]);
		super.new(name, points);
	endfunction
	
	function real get_area();
		return -1;
	endfunction : get_area
	
endclass : polygon_c


class rectangle_c extends polygon_c;
	
	function new(string name, point_c points[4]);	// 4 points
		super.new(name, points);
	endfunction
	
	function real get_area();
		real area = $sqrt(($pow((points[1].x-points[0].x), 2) + $pow((points[1].y-points[0].y), 2))*($pow((points[3].x-points[0].x), 2) + $pow((points[3].y-points[0].y), 2)));
		return area;
	endfunction : get_area
	
endclass : rectangle_c


class triangle_c extends polygon_c;
	
	function new(string name, point_c points[3]);	// 3 points
		super.new(name, points);
	endfunction
		
	function real get_area();
		real area = ((points[1].x-points[0].x)*(points[2].y-points[0].y) - (points[1].y-points[0].y)*(points[2].x-points[0].x))/2;
		if (area < 0) begin 
			return -area;	// $abs() not working - only on integers
		end
		return area;
	endfunction : get_area
		
endclass : triangle_c


class circle_c extends shape_c;
	
	function new(string name, point_c points[2]);	// 2 points
		super.new(name, points);
	endfunction
	
	protected function real get_radius_2();
		real radius_2 = $pow((points[1].x-points[0].x), 2) + $pow((points[1].y-points[0].y), 2);
		return radius_2;
	endfunction : get_radius_2
	
	function real get_area();
		real radius_2 = get_radius_2();
		real area = 3.14*radius_2;
		return area;
	endfunction : get_area
	
	function void print();
		$display("------------------------------");
		$display("This is: %0s ", name);
		$display("%0s", points[0].to_string());		// circle center
		$display("radius: %0.2f", $sqrt(get_radius_2()));
	endfunction : print
	
endclass : circle_c


///////////////////////////////////////////////////////////
//	REPORTER
///////////////////////////////////////////////////////////
class shape_reporter #(type T = shape_c);
	protected static T storage[$];	// contains type T objects
	
	static function void store_shape(T shape);
		storage.push_back(shape);
	endfunction : store_shape
	
	static function void report_shapes();
		foreach(storage[i]) begin
			real shape_area = storage[i].get_area();
			
			storage[i].print();
			
			if (shape_area == -1) begin
				$display("Area is: can not be calculated for generic %s.", storage[i].name);
			end
			else begin
				$display("Area is: %0.2f ", shape_area);
			end
		end
	endfunction : report_shapes
   
endclass : shape_reporter


///////////////////////////////////////////////////////////
//	FACTORY
///////////////////////////////////////////////////////////
class shape_factory;
   static function shape_c make_shape(point_c points[$]);
	   
	   polygon_c polygon;
	   rectangle_c rectangle;
	   triangle_c triangle;
	   circle_c circle;
	   
	   case (points.size())
		   //circle:
		   2 : begin
			   circle = new("circle", points);
			   shape_reporter #(circle_c)::store_shape(circle);
			   return circle;
			end
		   //triangle:
		   3 : begin
			   triangle = new("triangle", points);
			   shape_reporter #(triangle_c)::store_shape(triangle);
			   return triangle;
			end
		   //rectangle:
		   4 :  begin
			   rectangle = new("rectangle", points);
			   shape_reporter #(rectangle_c)::store_shape(rectangle);
			   return rectangle;
			end
		   //polygon:
        	default : begin
			   polygon = new("polygon", points);
	        	shape_reporter #(polygon_c)::store_shape(polygon);
			   return polygon;
	    	end
		endcase // case (shape_name)
      
   endfunction : make_shape
   
endclass : shape_factory


///////////////////////////////////////////////////////////
//	TOP
///////////////////////////////////////////////////////////
module top;
	
	initial begin
		shape_c shape;
		point_c point;
		point_c points[$];
		
		int fd_r, s_ret;
		real x;
		real y;
		byte last_char;
		
		fd_r = $fopen("./lab04part1_shapes.txt", "r");	// open in the read mode - run folder
		while (!$feof(fd_r)) begin						// do while until end of file
			s_ret = $fscanf(fd_r, "%f %f%c", x, y, last_char);
			point = new(x, y);							// make pair of 2 real numbers (x and y) - point
			points.push_back(point);					// push points to point_c points
			
			if(last_char == "\n") begin					// if end of line in .txt - make shape
				shape = shape_factory::make_shape(points);
				points.delete();						// clear queue
			end
		end
		$fclose(fd_r);
		
		shape_reporter #(circle_c)::report_shapes();
		shape_reporter #(triangle_c)::report_shapes();
		shape_reporter #(rectangle_c)::report_shapes();
		shape_reporter #(polygon_c)::report_shapes();
	end
	
endmodule : top

