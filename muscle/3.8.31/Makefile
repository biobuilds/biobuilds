muscle: $(ObjFiles)
	$(CXX) -o $@ $(LDFLAGS) -lm $^

%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) -D_FILE_OFFSET_BITS=64 -DNDEBUG=1 -o $@ $<
