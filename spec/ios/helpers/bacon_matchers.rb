# 1.should.be truthy
# false.should.not.be truthy
def truthy()
  lambda { |obj| !!obj }
end

# 1.should.not.be falsey
# false.should..be falsey
def falsey()
  lambda { |obj| !obj }
end
