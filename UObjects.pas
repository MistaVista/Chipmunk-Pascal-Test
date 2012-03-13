unit UObjects;

interface

uses
  dglOpenGL, Geometry, Types, Chipmunk, dialogs, sysutils;

procedure DrawPlane(p0, p1: TPoint; wid: Real);
procedure DrawQuadMirror(Pos,Size: TVertex);
procedure DrawArrow(Pos: TVertex; Length: Real);
procedure DrawLine(p0, p1: TVertex);
procedure DrawQuadEasyTex(Pos,Size: TVertex);

// xTex, yTex are texture stretching factors
// i.e. if xTex = 1, yTex = 2 and size[0] = 1, size[1] = 2 there will be
//      no stretching
procedure DrawQuad(Pos, Size: TVertex; xTex, yTex: Real);

// Chipmunk objects
procedure DrawChipLine(p0, p1: cpVect);
procedure DrawChipPoly(num: Integer; vects: cpVectArray);

function cpVectToVertex(v: cpVect; z: Real): TVertex;

implementation


procedure DrawPlane(p0, p1: TPoint; wid: Real);
begin

glBegin(GL_TRIANGLES);
  glTexCoord2f(0,0);
  glVertex3f(p0.X, p0.Y, 0);
  glTexCoord2f(0,1);
  glVertex3f(p1.X, p1.Y, 0);
  glTexCoord2f(1,0);
  glVertex3f(p0.X, p0.Y, wid);
glEnd;

glBegin(GL_TRIANGLES);
  glTexCoord2f(1,0);
  glVertex3f(p0.X, p0.Y, wid);
  glTexCoord2f(0,1);
  glVertex3f(p1.X, p1.Y, 0);
  glTexCoord2f(1,1);
  glVertex3f(p1.X, p1.Y, wid);
glEnd;

end;

procedure DrawQuadEasyTex(Pos,Size: TVertex);
begin

	// triangle left top
	glBegin(GL_TRIANGLES);
		glTexCoord2f(0,1);
		glVertex3f(Pos[0],Pos[1] + Size[1],Pos[2]);
		glTexCoord2f(0,0);
		glVertex3f(Pos[0],Pos[1],Pos[2]);
		glTexCoord2f(1,1);
		glVertex3f(Pos[0] + Size[0],Pos[1] + Size[1],Pos[2] + Size[2]);
	glEnd;
	// triangle right bottom
	glBegin(GL_TRIANGLES);
		glTexCoord2f(0,0);
		glVertex3f(Pos[0],Pos[1],Pos[2]);
		glTexCoord2f(1,0);
		glVertex3f(Pos[0] + Size[0],Pos[1],Pos[2] + Size[2]);
		glTexCoord2f(1,1);
		glVertex3f(Pos[0] + Size[0],Pos[1] + Size[1],Pos[2] + Size[2]);
	glEnd;

end;

procedure DrawQuad(Pos, Size: TVertex; xTex, yTex: Real);
var xFac, yFac: Real;
begin
  xFac := Size[0] / xTex;
  yFac := Size[1] / yTex;

	// triangle left top
	glBegin(GL_TRIANGLES);
		glTexCoord2f(0,yFac);
		glVertex3f(Pos[0],Pos[1] + Size[1],Pos[2]);
		glTexCoord2f(0,0);
		glVertex3f(Pos[0],Pos[1],Pos[2]);
		glTexCoord2f(xFac, yFac);
		glVertex3f(Pos[0] + Size[0],Pos[1] + Size[1],Pos[2] + Size[2]);
	glEnd;
	// triangle right bottom
	glBegin(GL_TRIANGLES);
		glTexCoord2f(0,0);
		glVertex3f(Pos[0],Pos[1],Pos[2]);
		glTexCoord2f(xFac ,0);
		glVertex3f(Pos[0] + Size[0],Pos[1],Pos[2] + Size[2]);
		glTexCoord2f(xFac, yFac);
		glVertex3f(Pos[0] + Size[0],Pos[1] + Size[1],Pos[2] + Size[2]);
	glEnd;

end;

procedure DrawQuadMirror(Pos,Size: TVertex);
begin

	// triangle left top
	glBegin(GL_TRIANGLES);
		glTexCoord2f(1,1);
		glVertex3f(Pos[0],Pos[1] + Size[1],Pos[2]);                   // top left
		glTexCoord2f(1,0);
		glVertex3f(Pos[0],Pos[1],Pos[2]);                             // bottom left
		glTexCoord2f(0,1);
		glVertex3f(Pos[0] + Size[0],Pos[1] + Size[1],Pos[2] + Size[2]);   // top right
	glEnd;
	// triangle right bottom
	glBegin(GL_TRIANGLES);
		glTexCoord2f(1,0);
		glVertex3f(Pos[0],Pos[1],Pos[2]);             // bottom left
		glTexCoord2f(0,0);
		glVertex3f(Pos[0] + Size[0],Pos[1],Pos[2] + Size[2]);  // bottom right
		glTexCoord2f(0,1);
		glVertex3f(Pos[0] + Size[0],Pos[1] + Size[1],Pos[2] + Size[2]); // top right
	glEnd;

end;

procedure DrawArrow(Pos: TVertex; length: Real);
begin

  glBegin(GL_TRIANGLES);
    glTexCoord2f(0,1);
    glVertex3fv(@Pos);
    glTexCoord2f(0,0);
    glVertex3f(Pos[0] + length / 10, Pos[1] + length, Pos[2]);
    glTexCoord2f(1,1);
    glVertex3f(Pos[0] + length / 5,  Pos[1], Pos[2]);
  glEnd;

end;

procedure DrawLine(p0,p1: TVertex);
begin
  glBegin(GL_LINES);
    glVertex3fv(@p0);
    glVertex3fv(@p1);
  glEnd;
end;

procedure DrawChipLine(p0,p1: cpVect);
var v0, v1: TVertex;
begin
v0[0] := p0.x;
v0[1] := p0.y;
v0[2] := 0;

v1[0] := p1.x;
v1[1] := p1.y;
v1[2] := 0;

  glBegin(GL_LINES);
    glVertex3fv(@v0);
    glVertex3fv(@v1);
  glEnd;
  
end;

procedure DrawChipPoly(num: Integer; vects: cpVectArray);
var i: Integer;
    v: TVertex;
begin
// must run the array the otherway around because glPoly wants
// counter clockwise, while chipmunk has clockwise

glBegin(GL_POLYGON);
  for i := num-1 downto 0 do begin
    v := cpVectToVertex(vects[i], 0);
    glTexCoord2f(v[0],v[1]);
    glVertex3fv(@v);
    end;
glEnd;

end;

function cpVectToVertex(v: cpVect; z: Real): TVertex;
begin
  result[0] := v.x;
  result[1] := v.y;
  result[2] := z;
end;

end.
 